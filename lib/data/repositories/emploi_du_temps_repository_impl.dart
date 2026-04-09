import '../../domain/entities/emploi_du_temps.dart';
import '../../domain/repositories/emploi_du_temps_repository.dart';
import '../datasources/emploi_du_temps_datasource.dart';

class EmploiDuTempsRepositoryImpl implements EmploiDuTempsRepository {
  final EmploiDuTempsDatasource _datasource;

  EmploiDuTempsRepositoryImpl(this._datasource);

  @override
  Stream<List<CreneauHoraire>> getEmploiByClasse(String classeId) =>
      _datasource.getEmploiByClasse(classeId);

  @override
  Stream<List<CreneauHoraire>> getEmploiByProfesseur(String professeurId) =>
      _datasource.getEmploiByProfesseur(professeurId);

  @override
  Future<void> addCreneau(CreneauHoraire creneau) =>
      _datasource.addCreneau(creneau);

  @override
  Future<void> updateCreneau(CreneauHoraire creneau) =>
      _datasource.updateCreneau(creneau);

  @override
  Future<void> deleteCreneau(String creneauId) =>
      _datasource.deleteCreneau(creneauId);
}
