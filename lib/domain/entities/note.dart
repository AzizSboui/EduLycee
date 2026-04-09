import 'package:equatable/equatable.dart';

enum TypeEvaluation { devoir, controle, examen, oral, tp, projet }

class Note extends Equatable {
  final String id;
  final String eleveId;
  final String matiereId;
  final String professeurId;
  final double valeur;
  final double coefficient;
  final TypeEvaluation typeEvaluation;
  final String? commentaire;
  final DateTime date;
  final String? competenceId;
  final String? periodeId;
  final String? titre;

  const Note({
    required this.id,
    required this.eleveId,
    required this.matiereId,
    required this.professeurId,
    required this.valeur,
    required this.coefficient,
    required this.typeEvaluation,
    this.commentaire,
    required this.date,
    this.competenceId,
    this.periodeId,
    this.titre,
  });

  @override
  List<Object?> get props => [id, eleveId, matiereId, valeur, date];
}
