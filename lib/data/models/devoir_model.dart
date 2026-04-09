import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/devoir.dart';

class DevoirModel extends Devoir {
  const DevoirModel({
    required super.id,
    required super.titre,
    required super.description,
    required super.matiereId,
    required super.classeId,
    required super.professeurId,
    required super.datePublication,
    required super.dateRendu,
    super.renduEnLigne,
    super.pieceJointesUrls,
  });

  factory DevoirModel.fromFirestore(Map<String, dynamic> data, String id) {
    return DevoirModel(
      id: id,
      titre: data['titre'] ?? '',
      description: data['description'] ?? '',
      matiereId: data['matiereId'] ?? '',
      classeId: data['classeId'] ?? '',
      professeurId: data['professeurId'] ?? '',
      datePublication: (data['datePublication'] as Timestamp).toDate(),
      dateRendu: (data['dateRendu'] as Timestamp).toDate(),
      renduEnLigne: data['renduEnLigne'] ?? false,
      pieceJointesUrls: List<String>.from(data['pieceJointesUrls'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'titre': titre,
        'description': description,
        'matiereId': matiereId,
        'classeId': classeId,
        'professeurId': professeurId,
        'datePublication': Timestamp.fromDate(datePublication),
        'dateRendu': Timestamp.fromDate(dateRendu),
        'renduEnLigne': renduEnLigne,
        'pieceJointesUrls': pieceJointesUrls,
      };
}
