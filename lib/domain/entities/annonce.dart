import 'package:equatable/equatable.dart';

class Annonce extends Equatable {
  final String id;
  final String titre;
  final String contenu;
  final String auteurId;
  final DateTime datePublication;
  final List<String> destinatairesRoles;
  final bool important;
  final String? imageUrl;

  const Annonce({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.auteurId,
    required this.datePublication,
    this.destinatairesRoles = const [],
    this.important = false,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, titre, datePublication];
}
