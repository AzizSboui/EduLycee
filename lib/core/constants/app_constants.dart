class AppConstants {
  static const String appName = 'EduLycée';
  static const String appVersion = '1.0.0';

  // Firestore collections
  static const String usersCollection = 'utilisateurs';
  static const String elevesCollection = 'eleves';
  static const String notesCollection = 'notes';
  static const String classesCollection = 'classes';
  static const String matieresCollection = 'matieres';
  static const String emploiDuTempsCollection = 'emploi_du_temps';
  static const String messagesCollection = 'messages';
  static const String devoirsCollection = 'devoirs';
  static const String absencesCollection = 'absences';
  static const String annoncesCollection = 'annonces';
  static const String periodesCollection = 'periodes';
  static const String bulletinsCollection = 'bulletins';

  // User roles
  static const String roleEleve = 'eleve';
  static const String roleProfesseur = 'professeur';
  static const String roleParent = 'parent';
  static const String roleAdmin = 'admin';
  static const String roleVieScolaire = 'vie_scolaire';

  // SharedPreferences keys
  static const String prefUserRole = 'user_role';
  static const String prefUserId = 'user_id';
  static const String prefThemeMode = 'theme_mode';
}
