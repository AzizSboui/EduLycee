import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../models/message_model.dart';
import '../models/annonce_model.dart';
import '../models/devoir_model.dart';

class CommunicationDatasource {
  final FirebaseFirestore _firestore;

  CommunicationDatasource(this._firestore);

  String _conversationId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Stream<List<MessageModel>> getConversation(String userId1, String userId2) {
    final convId = _conversationId(userId1, userId2);
    return _firestore
        .collection(AppConstants.messagesCollection)
        .where('conversationId', isEqualTo: convId)
        .orderBy('dateEnvoi', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MessageModel.fromFirestore(d.data(), d.id))
            .toList());
  }

  Stream<List<MessageModel>> getInbox(String userId) {
    return _firestore
        .collection(AppConstants.messagesCollection)
        .where('destinataireId', isEqualTo: userId)
        .orderBy('dateEnvoi', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MessageModel.fromFirestore(d.data(), d.id))
            .toList());
  }

  Future<void> sendMessage(MessageModel message) async {
    await _firestore
        .collection(AppConstants.messagesCollection)
        .doc(message.id)
        .set(message.toFirestore());
  }

  Future<void> markAsRead(String messageId) async {
    await _firestore
        .collection(AppConstants.messagesCollection)
        .doc(messageId)
        .update({'lu': true});
  }

  Stream<List<AnnonceModel>> getAnnonces({String? role}) {
    Query query = _firestore
        .collection(AppConstants.annoncesCollection)
        .orderBy('datePublication', descending: true);
    if (role != null) {
      query = query.where('destinatairesRoles', arrayContains: role);
    }
    return query.snapshots().map((snap) => snap.docs
        .map((d) => AnnonceModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
        .toList());
  }

  Future<void> createAnnonce(AnnonceModel annonce) async {
    await _firestore
        .collection(AppConstants.annoncesCollection)
        .doc(annonce.id)
        .set(annonce.toFirestore());
  }

  Stream<List<DevoirModel>> getDevoirsByClasse(String classeId) {
    return _firestore
        .collection(AppConstants.devoirsCollection)
        .where('classeId', isEqualTo: classeId)
        .orderBy('dateRendu')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => DevoirModel.fromFirestore(d.data(), d.id))
            .toList());
  }

  Future<void> createDevoir(DevoirModel devoir) async {
    await _firestore
        .collection(AppConstants.devoirsCollection)
        .doc(devoir.id)
        .set(devoir.toFirestore());
  }

  Future<void> updateDevoir(DevoirModel devoir) async {
    await _firestore
        .collection(AppConstants.devoirsCollection)
        .doc(devoir.id)
        .update(devoir.toFirestore());
  }
}
