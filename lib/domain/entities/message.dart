import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String expediteurId;
  final String destinataireId;
  final String contenu;
  final DateTime dateEnvoi;
  final bool lu;
  final String? pieceJointeUrl;
  final String? conversationId;

  const Message({
    required this.id,
    required this.expediteurId,
    required this.destinataireId,
    required this.contenu,
    required this.dateEnvoi,
    this.lu = false,
    this.pieceJointeUrl,
    this.conversationId,
  });

  @override
  List<Object?> get props => [id, expediteurId, destinataireId, dateEnvoi];
}
