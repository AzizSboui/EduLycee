import '../entities/classe.dart';
import '../entities/matiere.dart';

abstract class ClassesRepository {
  Stream<List<Classe>> getAllClasses();
  Future<Classe?> getClasseById(String classeId);
  Future<void> createClasse(Classe classe);
  Future<void> updateClasse(Classe classe);
  Future<void> deleteClasse(String classeId);
  Stream<List<Matiere>> getAllMatieres();
  Future<Matiere?> getMatiereById(String matiereId);
}
