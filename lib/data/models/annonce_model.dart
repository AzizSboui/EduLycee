import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/annonce.dart';

class AnnonceModel extends Annonce {
  const AnnonceModel({
    required super.id,
    required super.titre,
    required super.contenu,
    required super.auteurId,
    required super.datePublication,
    super.destinatairesRoles,
    super.important,
    super.imageUrl,
  });

  factory AnnonceModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AnnonceModel(
      id: id,
      titre: data['titre'] ?? '',
      contenu: data['contenu'] ?? '',
      auteurId: data['auteurId'] ?? '',
      datePublication: (data['datePublication'] as Timestamp).toDate(),
      destinatairesRoles: List<String>.from(data['destinatairesRoles'] ?? []),
      important: data['important'] ?? false,
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'titre': titre,
        'contenu': contenu,
        'auteurId': auteurId,
        'datePublication': Timestamp.fromDate(datePublication),
        'destinatairesRoles': destinatairesRoles,
        'important': important,
        'imageUrl': imageUrl,
      };
}
