import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/emploi_du_temps.dart';
import '../../../domain/repositories/emploi_du_temps_repository.dart';

// Events
abstract class EmploiEvent extends Equatable {
  const EmploiEvent();
  @override
  List<Object?> get props => [];
}

class LoadEmploiByClasse extends EmploiEvent {
  final String classeId;
  const LoadEmploiByClasse(this.classeId);
  @override
  List<Object?> get props => [classeId];
}

class LoadEmploiByProfesseur extends EmploiEvent {
  final String professeurId;
  const LoadEmploiByProfesseur(this.professeurId);
  @override
  List<Object?> get props => [professeurId];
}

class AddCreneau extends EmploiEvent {
  final CreneauHoraire creneau;
  const AddCreneau(this.creneau);
  @override
  List<Object?> get props => [creneau];
}

class DeleteCreneau extends EmploiEvent {
  final String creneauId;
  const DeleteCreneau(this.creneauId);
  @override
  List<Object?> get props => [creneauId];
}

// States
abstract class EmploiState extends Equatable {
  const EmploiState();
  @override
  List<Object?> get props => [];
}

class EmploiInitial extends EmploiState {}
class EmploiLoading extends EmploiState {}

class EmploiLoaded extends EmploiState {
  final List<CreneauHoraire> creneaux;
  const EmploiLoaded(this.creneaux);
  @override
  List<Object?> get props => [creneaux];
}

class EmploiError extends EmploiState {
  final String message;
  const EmploiError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class EmploiDuTempsBloc extends Bloc<EmploiEvent, EmploiState> {
  final EmploiDuTempsRepository _repository;

  EmploiDuTempsBloc(this._repository) : super(EmploiInitial()) {
    on<LoadEmploiByClasse>(_onLoadByClasse);
    on<LoadEmploiByProfesseur>(_onLoadByProfesseur);
    on<AddCreneau>(_onAddCreneau);
    on<DeleteCreneau>(_onDeleteCreneau);
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

  Future<void> _onAddCreneau(
      AddCreneau event, Emitter<EmploiState> emit) async {
    try {
      await _repository.addCreneau(event.creneau);
    } catch (e) {
      emit(EmploiError(e.toString()));
    }
  }

  Future<void> _onDeleteCreneau(
      DeleteCreneau event, Emitter<EmploiState> emit) async {
    try {
      await _repository.deleteCreneau(event.creneauId);
    } catch (e) {
      emit(EmploiError(e.toString()));
    }
  }
}
