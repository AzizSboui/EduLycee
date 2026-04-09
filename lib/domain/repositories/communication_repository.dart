import '../entities/message.dart';
import '../entities/annonce.dart';
import '../entities/devoir.dart';

abstract class CommunicationRepository {
  Stream<List<Message>> getConversation(String userId1, String userId2);
  Stream<List<Message>> getInbox(String userId);
  Future<void> sendMessage(Message message);
  Future<void> markAsRead(String messageId);
  Stream<List<Annonce>> getAnnonces({String? role});
  Future<void> createAnnonce(Annonce annonce);
  Stream<List<Devoir>> getDevoirsByClasse(String classeId);
  Stream<List<Devoir>> getDevoirsByEleve(String eleveId);
  Future<void> createDevoir(Devoir devoir);
  Future<void> updateDevoir(Devoir devoir);
}
