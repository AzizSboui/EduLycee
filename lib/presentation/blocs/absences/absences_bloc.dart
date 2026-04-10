import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/absence.dart';
import '../../../domain/repositories/absences_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────
abstract class AbsencesEvent extends Equatable {
  const AbsencesEvent();
  @override
  List<Object?> get props => [];
}

class AbsencesLoadByEleve extends AbsencesEvent {
  final String eleveId;
  const AbsencesLoadByEleve(this.eleveId);
  @override
  List<Object?> get props => [eleveId];
}

class AbsenceJustifier extends AbsencesEvent {
  final String absenceId;
  final String motif;
  const AbsenceJustifier(this.absenceId, this.motif);
  @override
  List<Object?> get props => [absenceId, motif];
}

class AbsenceSignaler extends AbsencesEvent {
  final Absence absence;
  const AbsenceSignaler(this.absence);
  @override
  List<Object?> get props => [absence];
}

// ── States ────────────────────────────────────────────────────────────────────
abstract class AbsencesState extends Equatable {
  const AbsencesState();
  @override
  List<Object?> get props => [];
}

class AbsencesInitial extends AbsencesState {}
class AbsencesLoading extends AbsencesState {}

class AbsencesLoaded extends AbsencesState {
  final List<Absence> absences;
  final int totalAbsences;
  final int absencesJustifiees;
  final int retards;

  const AbsencesLoaded({
    required this.absences,
    required this.totalAbsences,
    required this.absencesJustifiees,
    required this.retards,
  });

  int get nonJustifiees => totalAbsences - absencesJustifiees;

  @override
  List<Object?> get props => [absences, totalAbsences, absencesJustifiees, retards];
}

class AbsencesError extends AbsencesState {
  final String message;
  const AbsencesError(this.message);
  @override
  List<Object?> get props => [message];
}

class AbsenceOperationSuccess extends AbsencesState {
  final String message;
  const AbsenceOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────
class AbsencesBloc extends Bloc<AbsencesEvent, AbsencesState> {
  final AbsencesRepository _repository;

  AbsencesBloc(this._repository) : super(AbsencesInitial()) {
    on<AbsencesLoadByEleve>(_onLoad);
    on<AbsenceJustifier>(_onJustifier);
    on<AbsenceSignaler>(_onSignaler);
  }

  Future<void> _onLoad(
      AbsencesLoadByEleve event, Emitter<AbsencesState> emit) async {
    emit(AbsencesLoading());
    await emit.forEach(
      _repository.getAbsencesByEleve(event.eleveId),
      onData: (absences) {
        int total = 0, justifiees = 0, retards = 0;
        for (final a in absences) {
          if (a.type == TypeAbsence.retard) {
            retards++;
          } else {
            total++;
            if (a.statut == StatutAbsence.justifiee) justifiees++;
          }
        }
        return AbsencesLoaded(
          absences: absences,
          totalAbsences: total,
          absencesJustifiees: justifiees,
          retards: retards,
        );
      },
      onError: (e, _) => AbsencesError(e.toString()),
    );
  }

  Future<void> _onJustifier(
      AbsenceJustifier event, Emitter<AbsencesState> emit) async {
    try {
      await _repository.justifierAbsence(event.absenceId, event.motif);
      emit(const AbsenceOperationSuccess('Absence justifiée'));
    } catch (e) {
      emit(AbsencesError(e.toString()));
    }
  }

  Future<void> _onSignaler(
      AbsenceSignaler event, Emitter<AbsencesState> emit) async {
    try {
      await _repository.signalerAbsence(event.absence);
      emit(const AbsenceOperationSuccess('Absence signalée'));
    } catch (e) {
      emit(AbsencesError(e.toString()));
    }
  }
}
