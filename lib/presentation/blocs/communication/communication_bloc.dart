import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/communication_repository.dart';
import 'communication_event.dart';
import 'communication_state.dart';

class CommunicationBloc extends Bloc<CommunicationEvent, CommunicationState> {
  final CommunicationRepository _repository;

  CommunicationBloc(this._repository) : super(CommunicationInitial()) {
    on<LoadInbox>(_onLoadInbox);
    on<LoadConversation>(_onLoadConversation);
    on<SendMessage>(_onSendMessage);
    on<LoadAnnonces>(_onLoadAnnonces);
    on<LoadDevoirs>(_onLoadDevoirs);
    on<CreateDevoir>(_onCreateDevoir);
  }

  Future<void> _onLoadInbox(
      LoadInbox event, Emitter<CommunicationState> emit) async {
    emit(CommunicationLoading());
    await emit.forEach(
      _repository.getInbox(event.userId),
      onData: (msgs) => InboxLoaded(msgs),
      onError: (e, _) => CommunicationError(e.toString()),
    );
  }

  Future<void> _onLoadConversation(
      LoadConversation event, Emitter<CommunicationState> emit) async {
    emit(CommunicationLoading());
    await emit.forEach(
      _repository.getConversation(event.userId1, event.userId2),
      onData: (msgs) => ConversationLoaded(msgs),
      onError: (e, _) => CommunicationError(e.toString()),
    );
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<CommunicationState> emit) async {
    try {
      await _repository.sendMessage(event.message);
      emit(const CommunicationSuccess('Message envoyé'));
    } catch (e) {
      emit(CommunicationError(e.toString()));
    }
  }

  Future<void> _onLoadAnnonces(
      LoadAnnonces event, Emitter<CommunicationState> emit) async {
    emit(CommunicationLoading());
    await emit.forEach(
      _repository.getAnnonces(role: event.role),
      onData: (annonces) => AnnoncesLoaded(annonces),
      onError: (e, _) => CommunicationError(e.toString()),
    );
  }

  Future<void> _onLoadDevoirs(
      LoadDevoirs event, Emitter<CommunicationState> emit) async {
    emit(CommunicationLoading());
    await emit.forEach(
      _repository.getDevoirsByClasse(event.classeId),
      onData: (devoirs) => DevoirsLoaded(devoirs),
      onError: (e, _) => CommunicationError(e.toString()),
    );
  }

  Future<void> _onCreateDevoir(
      CreateDevoir event, Emitter<CommunicationState> emit) async {
    try {
      await _repository.createDevoir(event.devoir);
      emit(const CommunicationSuccess('Devoir créé avec succès'));
    } catch (e) {
      emit(CommunicationError(e.toString()));
    }
  }
}
