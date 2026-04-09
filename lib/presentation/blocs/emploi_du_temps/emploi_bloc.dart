import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/emploi_du_temps_repository.dart';
import 'emploi_event.dart';
import 'emploi_state.dart';

class EmploiBloc extends Bloc<EmploiEvent, EmploiState> {
  final EmploiDuTempsRepository _repository;

  EmploiBloc(this._repository) : super(EmploiInitial()) {
    on<LoadEmploiByClasse>(_onLoadByClasse);
    on<LoadEmploiByProfesseur>(_onLoadByProfesseur);
  }

  Future<void> _onLoadByClasse(
      LoadEmploiByClasse event, Emitter<EmploiState> emit) async {
    emit(EmploiLoading());
    await emit.forEach(
      _repository.getEmploiByClasse(event.classeId),
      onData: (creneaux) => EmploiLoaded(creneaux),
      onError: (e, _) => EmploiError(e.toString()),
    );
  }

  Future<void> _onLoadByProfesseur(
      LoadEmploiByProfesseur event, Emitter<EmploiState> emit) async {
    emit(EmploiLoading());
    await emit.forEach(
      _repository.getEmploiByProfesseur(event.professeurId),
      onData: (creneaux) => EmploiLoaded(creneaux),
      onError: (e, _) => EmploiError(e.toString()),
    );
  }
}
