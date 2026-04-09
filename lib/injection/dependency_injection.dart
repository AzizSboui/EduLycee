import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../data/datasources/auth_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/mock_auth_repository.dart';
import '../data/repositories/mock_notes_repository.dart';
import '../data/repositories/mock_emploi_repository.dart';
import '../data/repositories/mock_devoirs_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/notes_repository.dart';
import '../domain/repositories/emploi_du_temps_repository.dart';
import '../domain/repositories/communication_repository.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/notes/notes_bloc.dart';
import '../presentation/blocs/emploi_du_temps/emploi_du_temps_bloc.dart';
import '../presentation/blocs/communication/communication_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDependencies({bool firebaseReady = false}) async {
  if (sl.isRegistered<AuthRepository>()) return;

  if (firebaseReady) {
    sl.registerLazySingleton(() => FirebaseAuth.instance);
    sl.registerLazySingleton(() => FirebaseFirestore.instance);
    sl.registerLazySingleton(() => AuthDatasource(sl(), sl()));
    sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  } else {
    sl.registerLazySingleton<AuthRepository>(() => MockAuthRepository());
  }

  sl.registerFactory(() => AuthBloc(sl()));

  // Notes
  sl.registerLazySingleton<NotesRepository>(() => MockNotesRepository());
  sl.registerFactory(() => NotesBloc(sl()));

  // Emploi du temps
  sl.registerLazySingleton<EmploiDuTempsRepository>(() => MockEmploiRepository());
  sl.registerFactory(() => EmploiDuTempsBloc(sl()));

  // Communication + Devoirs
  sl.registerLazySingleton<CommunicationRepository>(() => MockCommunicationRepository());
  sl.registerFactory(() => CommunicationBloc(sl()));
}
