import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../models/eleve_model.dart';

class ElevesDatasource {
  final FirebaseFirestore _firestore;

  ElevesDatasource(this._firestore);

  Stream<List<EleveModel>> getElevesByClasse(String classeId) {
    return _firestore
        .collection(AppConstants.elevesCollection)
        .where('classeId', isEqualTo: classeId)
        .where('statut', isEqualTo: 'actif')
        .orderBy('nom')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => EleveModel.fromFirestore(d.data(), d.id))
            .toList());
  }

  Future<EleveModel?> getEleveById(String eleveId) async {
    final doc = await _firestore
        .collection(AppConstants.elevesCollection)
        .doc(eleveId)
        .get();
    if (!doc.exists) return null;
    return EleveModel.fromFirestore(doc.data()!, doc.id);
  }

  Future<void> createEleve(EleveModel eleve) async {
    await _firestore
        .collection(AppConstants.elevesCollection)
        .doc(eleve.uid)
        .set(eleve.toFirestore());
  }

  Future<void> updateEleve(EleveModel eleve) async {
    await _firestore
        .collection(AppConstants.elevesCollection)
        .doc(eleve.uid)
        .update(eleve.toFirestore());
  }

  Future<void> deleteEleve(String eleveId) async {
    await _firestore
        .collection(AppConstants.elevesCollection)
        .doc(eleveId)
        .delete();
  }

  Future<List<EleveModel>> getElevesByParent(String parentId) async {
    final snap = await _firestore
        .collection(AppConstants.elevesCollection)
        .where('parentsIds', arrayContains: parentId)
        .get();
    return snap.docs.map((d) => EleveModel.fromFirestore(d.data(), d.id)).toList();
  }
}
