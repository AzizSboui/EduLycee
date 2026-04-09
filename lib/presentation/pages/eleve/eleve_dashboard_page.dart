import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../injection/dependency_injection.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/communication/communication_bloc.dart';
import '../../blocs/emploi_du_temps/emploi_du_temps_bloc.dart';
import '../../blocs/notes/notes_bloc.dart';
import '../../themes/app_theme.dart';
import 'devoirs_page.dart';
import 'emploi_du_temps_page.dart';
import 'notes_page.dart';

class EleveDashboardPage extends StatefulWidget {
  const EleveDashboardPage({super.key});

  @override
  State<EleveDashboardPage> createState() => _EleveDashboardPageState();
}

class _EleveDashboardPageState extends State<EleveDashboardPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.utilisateur : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(user: user),
          BlocProvider(
            create: (_) => sl<NotesBloc>(),
            child: const NotesPage(),
          ),
          BlocProvider(
            create: (_) => sl<EmploiDuTempsBloc>(),
            child: EmploiDuTempsPage(classeId: user?.classeId ?? 'classe-001'),
          ),
          BlocProvider(
            create: (_) => sl<CommunicationBloc>(),
            child: DevoirsPage(classeId: user?.classeId ?? 'classe-001'),
          ),
          _ProfilTab(user: user),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.grade_outlined),
              activeIcon: Icon(Icons.grade),
              label: 'Notes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.schedule_outlined),
              activeIcon: Icon(Icons.schedule),
              label: 'Emploi du temps'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Devoirs'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil'),
        ],
      ),
    );
  }

  String get _appBarTitle {
    switch (_currentIndex) {
      case 1: return 'Mes Notes';
      case 2: return 'Emploi du temps';
      case 3: return 'Devoirs';
      case 4: return 'Mon Profil';
      default: return 'Tableau de bord';
    }
  }
}

// ── Accueil ──────────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final dynamic user;
  const _HomeTab({this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF2A5298)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bonjour, ${user?.prenom ?? 'Élève'} 👋',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(user?.email ?? '',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Text(
                    (user?.prenom ?? 'E').substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Accès rapide',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: const [
              _QuickCard(icon: Icons.grade, label: 'Mes Notes', color: AppColors.primary),
              _QuickCard(icon: Icons.schedule, label: 'Emploi du temps', color: AppColors.secondary),
              _QuickCard(icon: Icons.assignment, label: 'Devoirs', color: Color(0xFF9C27B0)),
              _QuickCard(icon: Icons.chat_bubble_outline, label: 'Messages', color: AppColors.accent),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Annonces',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _AnnonceCard(
            titre: 'Conseil de classe',
            contenu: 'Le conseil du 1er trimestre aura lieu le 15 janvier.',
            important: true,
          ),
          _AnnonceCard(
            titre: 'Sortie scolaire',
            contenu: 'Sortie au musée le 20 janvier. Autorisation requise.',
            important: false,
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickCard({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _AnnonceCard extends StatelessWidget {
  final String titre;
  final String contenu;
  final bool important;
  const _AnnonceCard({required this.titre, required this.contenu, required this.important});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: important ? Border.all(color: AppColors.secondary, width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (important)
            const Padding(
              padding: EdgeInsets.only(right: 10, top: 2),
              child: Icon(Icons.campaign, color: AppColors.secondary, size: 20),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titre, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14)),
                const SizedBox(height: 4),
                Text(contenu, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profil ───────────────────────────────────────────────────────────────────
class _ProfilTab extends StatelessWidget {
  final dynamic user;
  const _ProfilTab({this.user});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.primary,
            child: Text(
              (user?.prenom ?? 'E').substring(0, 1).toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(user?.fullName ?? '',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ),
        Center(
          child: Text(user?.email ?? '',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ),
        const SizedBox(height: 28),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: AppColors.error),
          title: const Text('Déconnexion', style: TextStyle(color: AppColors.error)),
          onTap: () => context.read<AuthBloc>().add(AuthSignOutRequested()),
        ),
      ],
    );
  }
}
