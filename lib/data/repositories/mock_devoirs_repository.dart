import '../../domain/entities/devoir.dart';
import '../../domain/repositories/communication_repository.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/annonce.dart';

class MockCommunicationRepository implements CommunicationRepository {
  final _devoirs = [
    Devoir(
      id: 'd1', titre: 'Exercices fonctions dérivées',
      description: 'Faire les exercices 12, 13, 14 page 87 du manuel.',
      matiereId: 'Mathématiques', classeId: 'classe-001',
      professeurId: 'prof-001',
      datePublication: DateTime(2025, 1, 20),
      dateRendu: DateTime(2025, 1, 27),
      renduEnLigne: false,
    ),
    Devoir(
      id: 'd2', titre: 'Dissertation — Le Rouge et le Noir',
      description: 'Rédiger une dissertation de 3 pages sur le personnage de Julien Sorel.',
      matiereId: 'Français', classeId: 'classe-001',
      professeurId: 'prof-002',
      datePublication: DateTime(2025, 1, 18),
      dateRendu: DateTime(2025, 1, 25),
      renduEnLigne: true,
    ),
    Devoir(
      id: 'd3', titre: 'Compte-rendu TP Optique',
      description: 'Rédiger le compte-rendu du TP sur la réfraction de la lumière.',
      matiereId: 'Physique', classeId: 'classe-001',
      professeurId: 'prof-003',
      datePublication: DateTime(2025, 1, 19),
      dateRendu: DateTime(2025, 2, 3),
      renduEnLigne: true,
    ),
    Devoir(
      id: 'd4', titre: 'Fiche de révision WW2',
      description: 'Préparer une fiche de révision sur les causes de la Seconde Guerre Mondiale.',
      matiereId: 'Histoire', classeId: 'classe-001',
      professeurId: 'prof-004',
      datePublication: DateTime(2025, 1, 15),
      dateRendu: DateTime(2025, 1, 22),
      renduEnLigne: false,
    ),
  ];

  @override
  Stream<List<Devoir>> getDevoirsByClasse(String classeId) =>
      Stream.value(_devoirs.where((d) => d.classeId == classeId).toList());

  @override
  Stream<List<Devoir>> getDevoirsByEleve(String eleveId) =>
      Stream.value(_devoirs);

  @override
  Future<void> createDevoir(Devoir devoir) async => _devoirs.add(devoir);

  @override
  Future<void> updateDevoir(Devoir devoir) async {}

  @override
  Stream<List<Message>> getConversation(String u1, String u2) => Stream.value([]);

  @override
  Stream<List<Message>> getInbox(String userId) => Stream.value([]);

  @override
  Future<void> sendMessage(Message message) async {}

  @override
  Future<void> markAsRead(String messageId) async {}

  @override
  Stream<List<Annonce>> getAnnonces({String? role}) => Stream.value([]);

  @override
  Future<void> createAnnonce(Annonce annonce) async {}
}
