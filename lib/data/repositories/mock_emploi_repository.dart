import '../../domain/entities/emploi_du_temps.dart';
import '../../domain/repositories/emploi_du_temps_repository.dart';

class MockEmploiRepository implements EmploiDuTempsRepository {
  final _creneaux = [
    // Lundi
    CreneauHoraire(id: 'c1', classeId: 'classe-001', matiereId: 'Mathématiques',
        professeurId: 'prof-001', salle: 'A101', jourSemaine: 1,
        heureDebut: '08:00', heureFin: '10:00', couleur: 'FF1A3A6B'),
    CreneauHoraire(id: 'c2', classeId: 'classe-001', matiereId: 'Français',
        professeurId: 'prof-002', salle: 'B203', jourSemaine: 1,
        heureDebut: '10:00', heureFin: '12:00', couleur: 'FFE87722'),
    CreneauHoraire(id: 'c3', classeId: 'classe-001', matiereId: 'Histoire',
        professeurId: 'prof-004', salle: 'C105', jourSemaine: 1,
        heureDebut: '14:00', heureFin: '16:00', couleur: 'FF9C27B0'),
    // Mardi
    CreneauHoraire(id: 'c4', classeId: 'classe-001', matiereId: 'Physique',
        professeurId: 'prof-003', salle: 'Labo1', jourSemaine: 2,
        heureDebut: '08:00', heureFin: '10:00', couleur: 'FF4CAF50'),
    CreneauHoraire(id: 'c5', classeId: 'classe-001', matiereId: 'Mathématiques',
        professeurId: 'prof-001', salle: 'A101', jourSemaine: 2,
        heureDebut: '10:00', heureFin: '12:00', couleur: 'FF1A3A6B'),
    // Mercredi
    CreneauHoraire(id: 'c6', classeId: 'classe-001', matiereId: 'Français',
        professeurId: 'prof-002', salle: 'B203', jourSemaine: 3,
        heureDebut: '08:00', heureFin: '10:00', couleur: 'FFE87722'),
    CreneauHoraire(id: 'c7', classeId: 'classe-001', matiereId: 'Anglais',
        professeurId: 'prof-005', salle: 'D301', jourSemaine: 3,
        heureDebut: '10:00', heureFin: '12:00', couleur: 'FF2196F3'),
    // Jeudi
    CreneauHoraire(id: 'c8', classeId: 'classe-001', matiereId: 'Histoire',
        professeurId: 'prof-004', salle: 'C105', jourSemaine: 4,
        heureDebut: '08:00', heureFin: '10:00', couleur: 'FF9C27B0'),
    CreneauHoraire(id: 'c9', classeId: 'classe-001', matiereId: 'Physique',
        professeurId: 'prof-003', salle: 'Labo1', jourSemaine: 4,
        heureDebut: '14:00', heureFin: '16:00', couleur: 'FF4CAF50'),
    // Vendredi
    CreneauHoraire(id: 'c10', classeId: 'classe-001', matiereId: 'Mathématiques',
        professeurId: 'prof-001', salle: 'A101', jourSemaine: 5,
        heureDebut: '08:00', heureFin: '10:00', couleur: 'FF1A3A6B'),
    CreneauHoraire(id: 'c11', classeId: 'classe-001', matiereId: 'Anglais',
        professeurId: 'prof-005', salle: 'D301', jourSemaine: 5,
        heureDebut: '10:00', heureFin: '12:00', couleur: 'FF2196F3'),
  ];

  @override
  Stream<List<CreneauHoraire>> getEmploiByClasse(String classeId) =>
      Stream.value(_creneaux.where((c) => c.classeId == classeId).toList());

  @override
  Stream<List<CreneauHoraire>> getEmploiByProfesseur(String professeurId) =>
      Stream.value(_creneaux.where((c) => c.professeurId == professeurId).toList());

  @override
  Future<void> addCreneau(CreneauHoraire creneau) async => _creneaux.add(creneau);

  @override
  Future<void> updateCreneau(CreneauHoraire creneau) async {}

  @override
  Future<void> deleteCreneau(String creneauId) async =>
      _creneaux.removeWhere((c) => c.id == creneauId);
}
