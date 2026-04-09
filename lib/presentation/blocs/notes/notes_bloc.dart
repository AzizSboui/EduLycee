import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/notes_repository.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesRepository _repository;
  StreamSubscription? _notesSubscription;

  NotesBloc(this._repository) : super(NotesInitial()) {
    on<NotesLoadByEleve>(_onLoadByEleve);
    on<NotesLoadByClasse>(_onLoadByClasse);
    on<NoteAjouter>(_onAjouter);
    on<NoteModifier>(_onModifier);
    on<NoteSupprimer>(_onSupprimer);
    on<NotesUpdated>(_onUpdated);
  }

  Future<void> _onLoadByEleve(
      NotesLoadByEleve event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    await _notesSubscription?.cancel();
    _notesSubscription =
        _repository.getNotesByEleve(event.eleveId, periodeId: event.periodeId).listen(
      (notes) => add(NotesUpdated(notes)),
      onError: (e) => emit(NotesError(e.toString())),
    );
    await emit.forEach(
      _repository.getNotesByEleve(event.eleveId, periodeId: event.periodeId),
      onData: (notes) {
        final moyennes = _calculerMoyennes(notes);
        final generale = moyennes.isEmpty
            ? 0.0
            : moyennes.values.reduce((a, b) => a + b) / moyennes.length;
        return NotesLoaded(
          notes: notes,
          moyennesParMatiere: moyennes,
          moyenneGenerale: generale,
        );
      },
      onError: (e, _) => NotesError(e.toString()),
    );
  }

  Future<void> _onLoadByClasse(
      NotesLoadByClasse event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    await emit.forEach(
      _repository.getNotesByClasse(event.classeId, event.matiereId),
      onData: (notes) => NotesLoaded(notes: notes),
      onError: (e, _) => NotesError(e.toString()),
    );
  }

  Future<void> _onAjouter(NoteAjouter event, Emitter<NotesState> emit) async {
    try {
      await _repository.ajouterNote(event.note);
      emit(const NoteOperationSuccess('Note ajoutée avec succès'));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onModifier(
      NoteModifier event, Emitter<NotesState> emit) async {
    try {
      await _repository.modifierNote(event.note);
      emit(const NoteOperationSuccess('Note modifiée avec succès'));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onSupprimer(
      NoteSupprimer event, Emitter<NotesState> emit) async {
    try {
      await _repository.supprimerNote(event.noteId);
      emit(const NoteOperationSuccess('Note supprimée'));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  void _onUpdated(NotesUpdated event, Emitter<NotesState> emit) {
    final moyennes = _calculerMoyennes(event.notes);
    final generale = moyennes.isEmpty
        ? 0.0
        : moyennes.values.reduce((a, b) => a + b) / moyennes.length;
    emit(NotesLoaded(
      notes: event.notes,
      moyennesParMatiere: moyennes,
      moyenneGenerale: generale,
    ));
  }

  Map<String, double> _calculerMoyennes(notes) {
    final Map<String, List<dynamic>> byMatiere = {};
    for (final n in notes) {
      byMatiere.putIfAbsent(n.matiereId, () => []).add(n);
    }
    final Map<String, double> moyennes = {};
    for (final entry in byMatiere.entries) {
      double total = 0, coeff = 0;
      for (final n in entry.value) {
        total += n.valeur * n.coefficient;
        coeff += n.coefficient;
      }
      moyennes[entry.key] = coeff == 0 ? 0 : total / coeff;
    }
    return moyennes;
  }

  @override
  Future<void> close() {
    _notesSubscription?.cancel();
    return super.close();
  }
}
