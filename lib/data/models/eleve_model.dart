import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/eleve.dart';

class EleveModel extends Eleve {
  const EleveModel({
    required super.uid,
    required super.nom,
    required super.prenom,
    required super.classeId,
    super.photoUrl,
    super.parentsIds,
    required super.dateInscription,
    super.statut,
    super.numeroEtudiant,
  });

  factory EleveModel.fromFirestore(Map<String, dynamic> data, String id) {
    return EleveModel(
      uid: id,
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      classeId: data['classeId'] ?? '',
      photoUrl: data['photoUrl'],
      parentsIds: List<String>.from(data['parentsIds'] ?? []),
      dateInscription: data['dateInscription'] != null
          ? (data['dateInscription'] as Timestamp).toDate()
          : DateTime.now(),
      statut: _parseStatut(data['statut']),
      numeroEtudiant: data['numeroEtudiant'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nom': nom,
        'prenom': prenom,
        'classeId': classeId,
        'photoUrl': photoUrl,
        'parentsIds': parentsIds,
        'dateInscription': Timestamp.fromDate(dateInscription),
        'statut': statut.name,
        'numeroEtudiant': numeroEtudiant,
      };

  static StatutScolaire _parseStatut(String? s) {
    switch (s) {
      case 'inactif':
        return StatutScolaire.inactif;
      case 'transfere':
        return StatutScolaire.transfere;
      case 'diplome':
        return StatutScolaire.diplome;
      default:
        return StatutScolaire.actif;
    }
  }
}
