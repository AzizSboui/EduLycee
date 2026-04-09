import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../models/absence_model.dart';

class AbsencesDatasource {
  final FirebaseFirestore _firestore;

  AbsencesDatasource(this._firestore);

  Stream<List<AbsenceModel>> getAbsencesByEleve(String eleveId) {
    return _firestore
        .collection(AppConstants.absencesCollection)
        .where('eleveId', isEqualTo: eleveId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AbsenceModel.fromFirestore(d.data(), d.id))
            .toList());
  }

  Stream<List<AbsenceModel>> getAbsencesByClasse(String classeId, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _firestore
        .collection(AppConstants.absencesCollection)
        .where('classeId', isEqualTo: classeId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AbsenceModel.fromFirestore(d.data(), d.id))
            .toList());
  }

  Future<void> signalerAbsence(AbsenceModel absence) async {
    await _firestore
        .collection(AppConstants.absencesCollection)
        .doc(absence.id)
        .set(absence.toFirestore());
  }

  Future<void> justifierAbsence(String absenceId, String motif,
      {String? justificatifUrl}) async {
    await _firestore
        .collection(AppConstants.absencesCollection)
        .doc(absenceId)
        .update({
      'statut': 'justifiee',
      'motif': motif,
      if (justificatifUrl != null) 'justificatifUrl': justificatifUrl,
    });
  }
}
