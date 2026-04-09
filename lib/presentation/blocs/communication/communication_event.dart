import 'package:equatable/equatable.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/devoir.dart';

abstract class CommunicationEvent extends Equatable {
  const CommunicationEvent();
  @override
  List<Object?> get props => [];
}

class LoadInbox extends CommunicationEvent {
  final String userId;
  const LoadInbox(this.userId);
  @override
  List<Object?> get props => [userId];
}

class LoadConversation extends CommunicationEvent {
  final String userId1;
  final String userId2;
  const LoadConversation(this.userId1, this.userId2);
  @override
  List<Object?> get props => [userId1, userId2];
}

class SendMessage extends CommunicationEvent {
  final Message message;
  const SendMessage(this.message);
  @override
  List<Object?> get props => [message];
}

class LoadAnnonces extends CommunicationEvent {
  final String? role;
  const LoadAnnonces({this.role});
  @override
  List<Object?> get props => [role];
}

class LoadDevoirs extends CommunicationEvent {
  final String classeId;
  const LoadDevoirs(this.classeId);
  @override
  List<Object?> get props => [classeId];
}

class CreateDevoir extends CommunicationEvent {
  final Devoir devoir;
  const CreateDevoir(this.devoir);
  @override
  List<Object?> get props => [devoir];
}
