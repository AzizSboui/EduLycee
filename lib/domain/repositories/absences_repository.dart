import '../entities/absence.dart';

abstract class AbsencesRepository {
  Stream<List<Absence>> getAbsencesByEleve(String eleveId);
  Stream<List<Absence>> getAbsencesByClasse(String classeId, DateTime date);
  Future<void> signalerAbsence(Absence absence);
  Future<void> justifierAbsence(String absenceId, String motif, {String? justificatifUrl});
  Future<Map<String, int>> getStatistiquesAbsences(String eleveId);
}
