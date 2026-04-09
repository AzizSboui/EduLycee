import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../themes/app_theme.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Administration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(AuthSignOutRequested()),
          ),
        ],
      ),
      body: _currentIndex == 0
          ? _buildOverview()
          : _currentIndex == 1
              ? _buildUsers()
              : _buildClasses(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Vue d\'ensemble'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), label: 'Utilisateurs'),
          BottomNavigationBarItem(
              icon: Icon(Icons.class_), label: 'Classes'),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Métriques établissement',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          
            childAspectRatio: 1.3,
            children: const [
              _MetricCard(
                  label: 'Élèves', value: '—', icon: Icons.people, color: AppColors.primary),
              _MetricCard(
                  label: 'Professeurs', value: '—', icon: Icons.school, color: AppColors.secondary),
              _MetricCard(
                  label: 'Classes', value: '—', icon: Icons.class_, color: Color(0xFF9C27B0)),
              _MetricCard(
                  label: 'Absences', value: '—', icon: Icons.event_busy, color: AppColors.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsers() {
    return const Center(
      child: Text('Gestion utilisateurs — prochaine étape',
          style: TextStyle(color: AppColors.textSecondary)),
    );
  }

  Widget _buildClasses() {
    return const Center(
      child: Text('Gestion classes — prochaine étape',
          style: TextStyle(color: AppColors.textSecondary)),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

