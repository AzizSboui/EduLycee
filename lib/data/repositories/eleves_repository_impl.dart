import '../../domain/entities/eleve.dart';
import '../../domain/repositories/eleves_repository.dart';
import '../datasources/eleves_datasource.dart';
import '../models/eleve_model.dart';

class ElevesRepositoryImpl implements ElevesRepository {
  final ElevesDatasource _datasource;

  ElevesRepositoryImpl(this._datasource);

  @override
  Stream<List<Eleve>> getElevesByClasse(String classeId) =>
      _datasource.getElevesByClasse(classeId);

  @override
  Future<Eleve?> getEleveById(String eleveId) =>
      _datasource.getEleveById(eleveId);

  @override
  Future<void> createEleve(Eleve eleve) =>
      _datasource.createEleve(eleve as EleveModel);

  @override
  Future<void> updateEleve(Eleve eleve) =>
      _datasource.updateEleve(eleve as EleveModel);

  @override
  Future<void> deleteEleve(String eleveId) =>
      _datasource.deleteEleve(eleveId);

  @override
  Future<List<Eleve>> getElevesByParent(String parentId) =>
      _datasource.getElevesByParent(parentId);
}
