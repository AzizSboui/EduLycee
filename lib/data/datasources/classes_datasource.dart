import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../models/classe_model.dart';
import '../models/matiere_model.dart';

class ClassesDatasource {
  final FirebaseFirestore _firestore;

  ClassesDatasource(this._firestore);

  Stream<List<ClasseModel>> getAllClasses() {
    return _firestore
        .collection(AppConstants.classesCollection)
        .orderBy('nom')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ClasseModel.fromFirestore(d.data(), d.id))
            .toList());
  }

  Future<ClasseModel?> getClasseById(String classeId) async {
    final doc = await _firestore
        .collection(AppConstants.classesCollection)
        .doc(classeId)
        .get();
    if (!doc.exists) return null;
    return ClasseModel.fromFirestore(doc.data()!, doc.id);
  }

  Future<void> createClasse(ClasseModel classe) async {
    await _firestore
        .collection(AppConstants.classesCollection)
        .doc(classe.id)
        .set(classe.toFirestore());
  }

  Future<void> updateClasse(ClasseModel classe) async {
    await _firestore
        .collection(AppConstants.classesCollection)
        .doc(classe.id)
        .update(classe.toFirestore());
  }

  Future<void> deleteClasse(String classeId) async {
    await _firestore
        .collection(AppConstants.classesCollection)
        .doc(classeId)
        .delete();
  }

  Stream<List<MatiereModel>> getAllMatieres() {
    return _firestore
        .collection(AppConstants.matieresCollection)
        .orderBy('nom')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MatiereModel.fromFirestore(d.data(), d.id))
            .toList());
  }

  Future<MatiereModel?> getMatiereById(String matiereId) async {
    final doc = await _firestore
        .collection(AppConstants.matieresCollection)
        .doc(matiereId)
        .get();
    if (!doc.exists) return null;
    return MatiereModel.fromFirestore(doc.data()!, doc.id);
  }
}
