import '../../domain/entities/message.dart';
import '../../domain/entities/annonce.dart';
import '../../domain/entities/devoir.dart';
import '../../domain/repositories/communication_repository.dart';
import '../datasources/communication_datasource.dart';
import '../models/message_model.dart';
import '../models/annonce_model.dart';
import '../models/devoir_model.dart';

class CommunicationRepositoryImpl implements CommunicationRepository {
  final CommunicationDatasource _datasource;

  CommunicationRepositoryImpl(this._datasource);

  @override
  Stream<List<Message>> getConversation(String userId1, String userId2) =>
      _datasource.getConversation(userId1, userId2);

  @override
  Stream<List<Message>> getInbox(String userId) =>
      _datasource.getInbox(userId);

  @override
  Future<void> sendMessage(Message message) =>
      _datasource.sendMessage(message as MessageModel);

  @override
  Future<void> markAsRead(String messageId) =>
      _datasource.markAsRead(messageId);

  @override
  Stream<List<Annonce>> getAnnonces({String? role}) =>
      _datasource.getAnnonces(role: role);

  @override
  Future<void> createAnnonce(Annonce annonce) =>
      _datasource.createAnnonce(annonce as AnnonceModel);

  @override
  Stream<List<Devoir>> getDevoirsByClasse(String classeId) =>
      _datasource.getDevoirsByClasse(classeId);

  @override
  Stream<List<Devoir>> getDevoirsByEleve(String eleveId) =>
      _datasource.getDevoirsByClasse(eleveId);

  @override
  Future<void> createDevoir(Devoir devoir) =>
      _datasource.createDevoir(devoir as DevoirModel);

  @override
  Future<void> updateDevoir(Devoir devoir) =>
      _datasource.updateDevoir(devoir as DevoirModel);
}
