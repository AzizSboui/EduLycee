import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'injection/dependency_injection.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/themes/app_theme.dart';
import 'firebase_options.dart'; // 🔥 IMPORTANT

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseOk = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // 🔥 IMPORTANT
    );
    firebaseOk = true;
  } catch (e) {
    debugPrint('Firebase non configuré: $e');
  }

  await setupDependencies(firebaseReady: firebaseOk);
  runApp(const EduLyceeApp());
}

class EduLyceeApp extends StatefulWidget {
  const EduLyceeApp({super.key});

  @override
  State<EduLyceeApp> createState() => _EduLyceeAppState();
}

class _EduLyceeAppState extends State<EduLyceeApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(AuthStarted());
    _router = AppRouter.router(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: 'EduLycée',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}