import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../injection/dependency_injection.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/notes/notes_bloc.dart';
import '../../themes/app_theme.dart';
import 'saisie_notes_page.dart';

class ProfesseurDashboardPage extends StatefulWidget {
  const ProfesseurDashboardPage({super.key});

  @override
  State<ProfesseurDashboardPage> createState() =>
      _ProfesseurDashboardPageState();
}

class _ProfesseurDashboardPageState extends State<ProfesseurDashboardPage> {
  int _currentIndex = 0;

  final _tabs = [
    const _ClassesTab(),
    BlocProvider(
      create: (_) => sl<NotesBloc>(),
      child: const SaisieNotesPage(),
    ),
    const _MessagesTab(),
    const _StatistiquesTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user =
            state is AuthAuthenticated ? state.utilisateur : null;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(_currentIndex == 0
                ? 'Mes Classes'
                : _currentIndex == 1
                    ? 'Saisie Notes'
                    : _currentIndex == 2
                        ? 'Messages'
                        : 'Statistiques'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: Text(
                    user?.fullName ?? '',
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () =>
                    context.read<AuthBloc>().add(AuthSignOutRequested()),
              ),
            ],
          ),
          body: _tabs[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.class_), label: 'Classes'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.grade), label: 'Saisie notes'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.chat), label: 'Messages'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.analytics), label: 'Statistiques'),
            ],
          ),
        );
      },
    );
  }
}

// ── Onglet Classes ──────────────────────────────────────────────────────────
class _ClassesTab extends StatelessWidget {
  const _ClassesTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ClassCard(nom: 'Terminale S1', eleves: 28, matiere: 'Mathématiques'),
        _ClassCard(nom: 'Première S2', eleves: 30, matiere: 'Mathématiques'),
        _ClassCard(nom: 'Seconde A', eleves: 32, matiere: 'Mathématiques'),
      ],
    );
  }
}

class _ClassCard extends StatelessWidget {
  final String nom;
  final int eleves;
  final String matiere;

  const _ClassCard(
      {required this.nom, required this.eleves, required this.matiere});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.class_, color: AppColors.primary),
        ),
        title: Text(nom,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$matiere • $eleves élèves'),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ),
    );
  }
}

// ── Onglet Messages ─────────────────────────────────────────────────────────
class _MessagesTab extends StatelessWidget {
  const _MessagesTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Messagerie — prochaine étape',
          style: TextStyle(color: AppColors.textSecondary)),
    );
  }
}

// ── Onglet Statistiques ─────────────────────────────────────────────────────
class _StatistiquesTab extends StatelessWidget {
  const _StatistiquesTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Statistiques — prochaine étape',
          style: TextStyle(color: AppColors.textSecondary)),
    );
  }
}

