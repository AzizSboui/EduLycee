import '../entities/note.dart';

abstract class NotesRepository {
  Stream<List<Note>> getNotesByEleve(String eleveId, {String? periodeId});
  Stream<List<Note>> getNotesByClasse(String classeId, String matiereId);
  Future<void> ajouterNote(Note note);
  Future<void> modifierNote(Note note);
  Future<void> supprimerNote(String noteId);
  Future<Map<String, double>> getMoyennesParMatiere(String eleveId, {String? periodeId});
  Future<double> getMoyenneGenerale(String eleveId, {String? periodeId});
}
