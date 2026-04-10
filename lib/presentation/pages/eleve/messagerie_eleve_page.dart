import 'package:flutter/material.dart';
import '../professeur/messagerie_page.dart';

/// Réutilise exactement la même MessageriePage —
/// le filtrage des contacts est géré par rôle dans _ContactsListView.
class MessagerieElevePage extends StatelessWidget {
  const MessagerieElevePage({super.key});

  @override
  Widget build(BuildContext context) => const MessageriePage();
}
