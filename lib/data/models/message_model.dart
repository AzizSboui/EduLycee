import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.expediteurId,
    required super.destinataireId,
    required super.contenu,
    required super.dateEnvoi,
    super.lu,
    super.pieceJointeUrl,
    super.conversationId,
  });

  factory MessageModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MessageModel(
      id: id,
      expediteurId: data['expediteurId'] ?? '',
      destinataireId: data['destinataireId'] ?? '',
      contenu: data['contenu'] ?? '',
      dateEnvoi: (data['dateEnvoi'] as Timestamp).toDate(),
      lu: data['lu'] ?? false,
      pieceJointeUrl: data['pieceJointeUrl'],
      conversationId: data['conversationId'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'expediteurId': expediteurId,
        'destinataireId': destinataireId,
        'contenu': contenu,
        'dateEnvoi': Timestamp.fromDate(dateEnvoi),
        'lu': lu,
        'pieceJointeUrl': pieceJointeUrl,
        'conversationId': conversationId,
      };
}
