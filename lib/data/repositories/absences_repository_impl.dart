import '../../domain/entities/absence.dart';
import '../../domain/repositories/absences_repository.dart';
import '../datasources/absences_datasource.dart';
import '../models/absence_model.dart';

class AbsencesRepositoryImpl implements AbsencesRepository {
  final AbsencesDatasource _datasource;

  AbsencesRepositoryImpl(this._datasource);

  @override
  Stream<List<Absence>> getAbsencesByEleve(String eleveId) =>
      _datasource.getAbsencesByEleve(eleveId);

  @override
  Stream<List<Absence>> getAbsencesByClasse(String classeId, DateTime date) =>
      _datasource.getAbsencesByClasse(classeId, date);

  @override
  Future<void> signalerAbsence(Absence absence) =>
      _datasource.signalerAbsence(absence as AbsenceModel);

  @override
  Future<void> justifierAbsence(String absenceId, String motif,
          {String? justificatifUrl}) =>
      _datasource.justifierAbsence(absenceId, motif,
          justificatifUrl: justificatifUrl);

  @override
  Future<Map<String, int>> getStatistiquesAbsences(String eleveId) async {
    final absences = await _datasource.getAbsencesByEleve(eleveId).first;
    int total = 0, justifiees = 0, retards = 0;
    for (final a in absences) {
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
