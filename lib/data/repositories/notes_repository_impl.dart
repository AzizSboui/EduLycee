import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_datasource.dart';
import '../models/note_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesDatasource _datasource;

  NotesRepositoryImpl(this._datasource);

  @override
  Stream<List<Note>> getNotesByEleve(String eleveId, {String? periodeId}) =>
      _datasource.getNotesByEleve(eleveId, periodeId: periodeId);

  @override
  Stream<List<Note>> getNotesByClasse(String classeId, String matiereId) =>
      _datasource.getNotesByClasse(classeId, matiereId);

  @override
  Future<void> ajouterNote(Note note) =>
      _datasource.ajouterNote(note as NoteModel);

  @override
  Future<void> modifierNote(Note note) =>
      _datasource.modifierNote(note as NoteModel);

  @override
  Future<void> supprimerNote(String noteId) =>
      _datasource.supprimerNote(noteId);

  @override
  Future<Map<String, double>> getMoyennesParMatiere(String eleveId,
      {String? periodeId}) async {
    final notes =
        await _datasource.getNotesListByEleve(eleveId, periodeId: periodeId);
    final Map<String, List<NoteModel>> byMatiere = {};
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
  Future<double> getMoyenneGenerale(String eleveId, {String? periodeId}) async {
    final moyennes =
        await getMoyennesParMatiere(eleveId, periodeId: periodeId);
    if (moyennes.isEmpty) return 0;
    return moyennes.values.reduce((a, b) => a + b) / moyennes.length;
  }
}
