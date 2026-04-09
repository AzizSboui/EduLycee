import 'package:equatable/equatable.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/annonce.dart';
import '../../../domain/entities/devoir.dart';

abstract class CommunicationState extends Equatable {
  const CommunicationState();
  @override
  List<Object?> get props => [];
}

class CommunicationInitial extends CommunicationState {}
class CommunicationLoading extends CommunicationState {}

class InboxLoaded extends CommunicationState {
  final List<Message> messages;
  const InboxLoaded(this.messages);
  @override
  List<Object?> get props => [messages];
}

class ConversationLoaded extends CommunicationState {
  final List<Message> messages;
  const ConversationLoaded(this.messages);
  @override
  List<Object?> get props => [messages];
}

class AnnoncesLoaded extends CommunicationState {
  final List<Annonce> annonces;
  const AnnoncesLoaded(this.annonces);
  @override
  List<Object?> get props => [annonces];
}

class DevoirsLoaded extends CommunicationState {
  final List<Devoir> devoirs;
  const DevoirsLoaded(this.devoirs);
  @override
  List<Object?> get props => [devoirs];
}

class CommunicationError extends CommunicationState {
  final String message;
  const CommunicationError(this.message);
  @override
  List<Object?> get props => [message];
}

class CommunicationSuccess extends CommunicationState {
  final String message;
  const CommunicationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
