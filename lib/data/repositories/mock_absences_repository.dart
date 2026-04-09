import '../../domain/entities/absence.dart';
import '../../domain/repositories/absences_repository.dart';

class MockAbsencesRepository implements AbsencesRepository {
  final _absences = [
    Absence(
      id: 'a1',
      eleveId: 'eleve-001',
      date: DateTime(2025, 1, 6),
      heureDebut: '08:00',
      heureFin: '10:00',
      type: TypeAbsence.absence,
      statut: StatutAbsence.justifiee,
      motif: 'Rendez-vous médical',
      matiereId: 'Mathématiques',
    ),
    Absence(
      id: 'a2',
      eleveId: 'eleve-001',
      date: DateTime(2025, 1, 13),
      heureDebut: '10:00',
      heureFin: '12:00',
      type: TypeAbsence.absence,
      statut: StatutAbsence.nonJustifiee,
      matiereId: 'Français',
    ),
    Absence(
      id: 'a3',
      eleveId: 'eleve-001',
      date: DateTime(2025, 1, 20),
      heureDebut: '08:00',
      heureFin: '08:30',
      type: TypeAbsence.retard,
      statut: StatutAbsence.justifiee,
      motif: 'Problème de transport',
      matiereId: 'Histoire',
    ),
    Absence(
      id: 'a4',
      eleveId: 'eleve-001',
      date: DateTime(2025, 2, 3),
      heureDebut: '14:00',
      heureFin: '16:00',
      type: TypeAbsence.absence,
      statut: StatutAbsence.enAttente,
      matiereId: 'Physique',
    ),
    Absence(
      id: 'a5',
      eleveId: 'eleve-001',
      date: DateTime(2025, 2, 10),
      heureDebut: '10:00',
      heureFin: '12:00',
      type: TypeAbsence.absence,
      statut: StatutAbsence.nonJustifiee,
      matiereId: 'Anglais',
    ),
  ];

  @override
  Stream<List<Absence>> getAbsencesByEleve(String eleveId) =>
      Stream.value(_absences.where((a) => a.eleveId == eleveId).toList());

  @override
  Stream<List<Absence>> getAbsencesByClasse(String classeId, DateTime date) =>
      Stream.value([]);

  @override
  Future<void> signalerAbsence(Absence absence) async =>
      _absences.add(absence);

  @override
  Future<void> justifierAbsence(String absenceId, String motif,
      {String? justificatifUrl}) async {
    final i = _absences.indexWhere((a) => a.id == absenceId);
    if (i == -1) return;
    final a = _absences[i];
    _absences[i] = Absence(
      id: a.id,
      eleveId: a.eleveId,
      date: a.date,
      heureDebut: a.heureDebut,
      heureFin: a.heureFin,
      type: a.type,
      statut: StatutAbsence.justifiee,
      motif: motif,
      justificatifUrl: justificatifUrl,
      matiereId: a.matiereId,
    );
  }

  @override
  Future<Map<String, int>> getStatistiquesAbsences(String eleveId) async {
    final list = _absences.where((a) => a.eleveId == eleveId).toList();
    int total = 0, justifiees = 0, retards = 0;
    for (final a in list) {
      if (a.type == TypeAbsence.retard) {
        retards++;
      } else {
        total++;
        if (a.statut == StatutAbsence.justifiee) justifiees++;
      }
    }
    return {'total': total, 'justifiees': justifiees, 'retards': retards};
  }
}
