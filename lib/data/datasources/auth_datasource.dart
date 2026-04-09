import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../models/utilisateur_model.dart';

class AuthDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthDatasource(this._auth, this._firestore);

  Future<UtilisateurModel> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _getUserData(credential.user!.uid);
  }

  // Crée uniquement le compte Auth — Firestore est géré par le Bloc
  Future<String> signUpGetUid(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    debugPrint('✅ Auth UID créé: ${credential.user!.uid}');
    return credential.user!.uid;
  }

  Future<void> signOut() => _auth.signOut();

  Future<UtilisateurModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      return await _getUserData(user.uid);
    } catch (e) {
      debugPrint('getCurrentUser error: $e');
      return null;
    }
  }

  Stream<UtilisateurModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        return await _getUserData(user.uid);
      } catch (e) {
        return null;
      }
    });
  }

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<UtilisateurModel> _getUserData(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) {
      throw Exception('Document utilisateur introuvable: $uid');
    }
    return UtilisateurModel.fromFirestore(doc.data()!, doc.id);
  }

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    await _auth.currentUser?.updateDisplayName(displayName);
    await _auth.currentUser?.updatePhotoURL(photoUrl);
  }

  // Crée le document Firestore directement
  Future<UtilisateurModel> createUserInFirestore({
    required String uid,
    required String nom,
    required String prenom,
    required String email,
    required String role,
  }) async {
    final data = {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'role': role,
      'classeId': null,
      'photoUrl': null,
      'matiereIds': [],
      'enfantsIds': [],
      'isActive': true,
    };

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .set(data);

    debugPrint('✅ Firestore document créé: utilisateurs/$uid');
    return UtilisateurModel.fromFirestore(data, uid);
  }
}
