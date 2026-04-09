import 'package:equatable/equatable.dart';
import '../../../domain/entities/note.dart';

abstract class NotesState extends Equatable {
  const NotesState();
  @override
  List<Object?> get props => [];
}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<Note> notes;
  final Map<String, double> moyennesParMatiere;
  final double moyenneGenerale;

  const NotesLoaded({
    required this.notes,
    this.moyennesParMatiere = const {},
    this.moyenneGenerale = 0,
  });

  @override
  List<Object?> get props => [notes, moyennesParMatiere, moyenneGenerale];
}

class NotesError extends NotesState {
  final String message;
  const NotesError(this.message);
  @override
  List<Object?> get props => [message];
}

class NoteOperationSuccess extends NotesState {
  final String message;
  const NoteOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
