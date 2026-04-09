import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/utilisateur.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_state.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/admin_pin_page.dart';
import '../../presentation/pages/eleve/eleve_dashboard_page.dart';
import '../../presentation/pages/professeur/professeur_dashboard_page.dart';
import '../../presentation/pages/admin/admin_dashboard_page.dart';
import '../../presentation/pages/shared/splash_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String eleveDashboard = '/eleve/dashboard';
  static const String professeurDashboard = '/professeur/dashboard';
  static const String adminDashboard = '/admin/dashboard';

  static GoRouter router(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: splash,
      refreshListenable: _AuthNotifier(authBloc),
      redirect: (context, state) {
        final authState = authBloc.state;
        final loc = state.matchedLocation;

        // Pendant le chargement → splash
        if (authState is AuthInitial || authState is AuthLoading) {
          return loc == splash ? null : splash;
        }

        // Non connecté → login
        if (authState is AuthUnauthenticated || authState is AuthError) {
          return loc == login ? null : login;
        }

        // Connecté → aller au bon dashboard si on est sur splash ou login
        if (authState is AuthAuthenticated) {
          final home = _homeForRole(authState.utilisateur.role);
          // Si on est sur splash, login, ou la racine → rediriger
          if (loc == splash || loc == login || loc == '/') {
            return home;
          }
          // Sinon on reste où on est
          return null;
        }

        return null;
      },
      routes: [
        GoRoute(path: splash, builder: (_, __) => const SplashPage()),
        GoRoute(path: login, builder: (_, __) => const LoginPage()),
        GoRoute(
          path: eleveDashboard,
          builder: (_, __) => const EleveDashboardPage(),
        ),
        GoRoute(
          path: professeurDashboard,
          builder: (_, __) => const ProfesseurDashboardPage(),
        ),
        GoRoute(
          path: adminDashboard,
          builder: (_, __) => const AdminDashboardPage(),
        ),
      ],
      errorBuilder: (_, state) => Scaffold(
        body: Center(child: Text('Erreur: ${state.error}')),
      ),
    );
  }

  static String _homeForRole(UserRole role) {
    switch (role) {
      case UserRole.professeur:
        return professeurDashboard;
      case UserRole.admin:
      case UserRole.vieScolaire:
        return adminDashboard;
      case UserRole.eleve:
      case UserRole.parent:
        return eleveDashboard;
    }
  }
}

class _AuthNotifier extends ChangeNotifier {
  final AuthBloc _authBloc;

  _AuthNotifier(this._authBloc) {
    _authBloc.stream.listen((_) => notifyListeners());
  }
}
