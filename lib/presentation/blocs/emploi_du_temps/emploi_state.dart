import 'package:equatable/equatable.dart';
import '../../../domain/entities/emploi_du_temps.dart';

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
