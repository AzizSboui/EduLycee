import 'package:equatable/equatable.dart';

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
