import 'package:equatable/equatable.dart';
import '../../../domain/entities/note.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();
  @override
  List<Object?> get props => [];
}

class NotesLoadByEleve extends NotesEvent {
  final String eleveId;
  final String? periodeId;
  const NotesLoadByEleve(this.eleveId, {this.periodeId});
  @override
  List<Object?> get props => [eleveId, periodeId];
}

class NotesLoadByClasse extends NotesEvent {
  final String classeId;
  final String matiereId;
  const NotesLoadByClasse(this.classeId, this.matiereId);
  @override
  List<Object?> get props => [classeId, matiereId];
}

class NoteAjouter extends NotesEvent {
  final Note note;
  const NoteAjouter(this.note);
  @override
  List<Object?> get props => [note];
}

class NoteModifier extends NotesEvent {
  final Note note;
  const NoteModifier(this.note);
  @override
  List<Object?> get props => [note];
}

class NoteSupprimer extends NotesEvent {
  final String noteId;
  const NoteSupprimer(this.noteId);
  @override
  List<Object?> get props => [noteId];
}

class NotesUpdated extends NotesEvent {
  final List<Note> notes;
  const NotesUpdated(this.notes);
  @override
  List<Object?> get props => [notes];
}
