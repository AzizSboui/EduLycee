import 'package:equatable/equatable.dart';

class Devoir extends Equatable {
  final String id;
  final String titre;
  final String description;
  final String matiereId;
  final String classeId;
  final String professeurId;
  final DateTime datePublication;
  final DateTime dateRendu;
  final bool renduEnLigne;
  final List<String> pieceJointesUrls;

  const Devoir({
    required this.id,
    required this.titre,
    required this.description,
    required this.matiereId,
    required this.classeId,
    required this.professeurId,
    required this.datePublication,
    required this.dateRendu,
    this.renduEnLigne = false,
    this.pieceJointesUrls = const [],
  });

  bool get isExpired => DateTime.now().isAfter(dateRendu);

  @override
  List<Object?> get props => [id, titre, matiereId, dateRendu];
}
