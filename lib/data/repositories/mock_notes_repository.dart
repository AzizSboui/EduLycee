import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';

class MockNotesRepository implements NotesRepository {
  final _notes = [
    Note(
      id: 'n1', eleveId: 'eleve-001', matiereId: 'Mathématiques',
      professeurId: 'prof-001', valeur: 15.5, coefficient: 3,
      typeEvaluation: TypeEvaluation.controle,
      date: DateTime(2025, 1, 10), titre: 'Contrôle fonctions',
      commentaire: 'Bon travail',
    ),
    Note(
      id: 'n2', eleveId: 'eleve-001', matiereId: 'Mathématiques',
      professeurId: 'prof-001', valeur: 12.0, coefficient: 2,
      typeEvaluation: TypeEvaluation.devoir,
      date: DateTime(2025, 1, 20), titre: 'Devoir maison',
    ),
    Note(
      id: 'n3', eleveId: 'eleve-001', matiereId: 'Français',
      professeurId: 'prof-002', valeur: 14.0, coefficient: 3,
      typeEvaluation: TypeEvaluation.examen,
      date: DateTime(2025, 1, 15), titre: 'Dissertation',
      commentaire: 'Très bonne analyse',
    ),
    Note(
      id: 'n4', eleveId: 'eleve-001', matiereId: 'Physique',
      professeurId: 'prof-003', valeur: 11.0, coefficient: 2,
      typeEvaluation: TypeEvaluation.tp,
      date: DateTime(2025, 1, 18), titre: 'TP Optique',
    ),
    Note(
      id: 'n5', eleveId: 'eleve-001', matiereId: 'Histoire',
      professeurId: 'prof-004', valeur: 16.0, coefficient: 2,
      typeEvaluation: TypeEvaluation.controle,
      date: DateTime(2025, 1, 22), titre: 'Contrôle WW2',
      commentaire: 'Excellent',
    ),
  ];

  @override
  Stream<List<Note>> getNotesByEleve(String eleveId, {String? periodeId}) =>
      Stream.value(_notes.where((n) => n.eleveId == eleveId).toList());

  @override
  Stream<List<Note>> getNotesByClasse(String classeId, String matiereId) =>
      Stream.value([]);

  @override
  Future<void> ajouterNote(Note note) async => _notes.add(note);

  @override
  Future<void> modifierNote(Note note) async {}

  @override
  Future<void> supprimerNote(String noteId) async =>
      _notes.removeWhere((n) => n.id == noteId);

  @override
  Future<Map<String, double>> getMoyennesParMatiere(String eleveId,
      {String? periodeId}) async {
    final notes = _notes.where((n) => n.eleveId == eleveId).toList();
    final Map<String, List<Note>> byMatiere = {};
    for (final n in notes) {
      byMatiere.putIfAbsent(n.matiereId, () => []).add(n);
    }
    final Map<String, double> moyennes = {};
    for (final e in byMatiere.entries) {
      double total = 0, coeff = 0;
      for (final n in e.value) {
        total += n.valeur * n.coefficient;
        coeff += n.coefficient;
      }
      moyennes[e.key] = coeff == 0 ? 0 : total / coeff;
    }
    return moyennes;
  }

  @override
  Future<double> getMoyenneGenerale(String eleveId, {String? periodeId}) async {
    final m = await getMoyennesParMatiere(eleveId);
    if (m.isEmpty) return 0;
    return m.values.reduce((a, b) => a + b) / m.length;
  }
}
