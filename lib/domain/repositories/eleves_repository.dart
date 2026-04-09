import '../entities/eleve.dart';

abstract class ElevesRepository {
  Stream<List<Eleve>> getElevesByClasse(String classeId);
  Future<Eleve?> getEleveById(String eleveId);
  Future<void> createEleve(Eleve eleve);
  Future<void> updateEleve(Eleve eleve);
  Future<void> deleteEleve(String eleveId);
  Future<List<Eleve>> getElevesByParent(String parentId);
}
