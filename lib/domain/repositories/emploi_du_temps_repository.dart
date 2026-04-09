import '../entities/emploi_du_temps.dart';

abstract class EmploiDuTempsRepository {
  Stream<List<CreneauHoraire>> getEmploiByClasse(String classeId);
  Stream<List<CreneauHoraire>> getEmploiByProfesseur(String professeurId);
  Future<void> addCreneau(CreneauHoraire creneau);
  Future<void> updateCreneau(CreneauHoraire creneau);
  Future<void> deleteCreneau(String creneauId);
}
