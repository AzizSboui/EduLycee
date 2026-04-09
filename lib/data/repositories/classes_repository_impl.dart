import '../../domain/entities/classe.dart';
import '../../domain/entities/matiere.dart';
import '../../domain/repositories/classes_repository.dart';
import '../datasources/classes_datasource.dart';
import '../models/classe_model.dart';

class ClassesRepositoryImpl implements ClassesRepository {
  final ClassesDatasource _datasource;

  ClassesRepositoryImpl(this._datasource);

  @override
  Stream<List<Classe>> getAllClasses() => _datasource.getAllClasses();

  @override
  Future<Classe?> getClasseById(String classeId) =>
      _datasource.getClasseById(classeId);

  @override
  Future<void> createClasse(Classe classe) =>
      _datasource.createClasse(classe as ClasseModel);

  @override
  Future<void> updateClasse(Classe classe) =>
      _datasource.updateClasse(classe as ClasseModel);

  @override
  Future<void> deleteClasse(String classeId) =>
      _datasource.deleteClasse(classeId);

  @override
  Stream<List<Matiere>> getAllMatieres() => _datasource.getAllMatieres();

  @override
  Future<Matiere?> getMatiereById(String matiereId) =>
      _datasource.getMatiereById(matiereId);
}
