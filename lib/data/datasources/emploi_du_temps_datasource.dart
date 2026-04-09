import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/emploi_du_temps.dart';

class EmploiDuTempsDatasource {
  final FirebaseFirestore _firestore;

  EmploiDuTempsDatasource(this._firestore);

  Stream<List<CreneauHoraire>> getEmploiByClasse(String classeId) {
    return _firestore
        .collection(AppConstants.emploiDuTempsCollection)
        .where('classeId', isEqualTo: classeId)
        .orderBy('jourSemaine')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => _fromMap(d.data(), d.id))
            .toList());
  }

  Stream<List<CreneauHoraire>> getEmploiByProfesseur(String professeurId) {
    return _firestore
        .collection(AppConstants.emploiDuTempsCollection)
        .where('professeurId', isEqualTo: professeurId)
        .orderBy('jourSemaine')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => _fromMap(d.data(), d.id))
            .toList());
  }

  Future<void> addCreneau(CreneauHoraire creneau) async {
    await _firestore
        .collection(AppConstants.emploiDuTempsCollection)
        .doc(creneau.id)
        .set(_toMap(creneau));
  }

  Future<void> updateCreneau(CreneauHoraire creneau) async {
    await _firestore
        .collection(AppConstants.emploiDuTempsCollection)
        .doc(creneau.id)
        .update(_toMap(creneau));
  }

  Future<void> deleteCreneau(String creneauId) async {
    await _firestore
        .collection(AppConstants.emploiDuTempsCollection)
        .doc(creneauId)
        .delete();
  }

  CreneauHoraire _fromMap(Map<String, dynamic> data, String id) {
    return CreneauHoraire(
      id: id,
      classeId: data['classeId'] ?? '',
      matiereId: data['matiereId'] ?? '',
      professeurId: data['professeurId'] ?? '',
      salle: data['salle'] ?? '',
      jourSemaine: data['jourSemaine'] ?? 1,
      heureDebut: data['heureDebut'] ?? '',
      heureFin: data['heureFin'] ?? '',
      couleur: data['couleur'],
    );
  }

  Map<String, dynamic> _toMap(CreneauHoraire c) => {
        'classeId': c.classeId,
        'matiereId': c.matiereId,
        'professeurId': c.professeurId,
        'salle': c.salle,
        'jourSemaine': c.jourSemaine,
        'heureDebut': c.heureDebut,
        'heureFin': c.heureFin,
        'couleur': c.couleur,
      };
}
