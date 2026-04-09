import 'package:equatable/equatable.dart';

class Matiere extends Equatable {
  final String id;
  final String nom;
  final String code;
  final double coefficient;
  final String? couleur;
  final String? icone;

  const Matiere({
    required this.id,
    required this.nom,
    required this.code,
    required this.coefficient,
    this.couleur,
    this.icone,
  });

  @override
  List<Object?> get props => [id, nom, code];
}
