import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../themes/app_theme.dart';

class AdminPinPage extends StatefulWidget {
  final String uid;
  const AdminPinPage({super.key, required this.uid});

  @override
  State<AdminPinPage> createState() => _AdminPinPageState();
}

class _AdminPinPageState extends State<AdminPinPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _loading = false;
  bool _error = false;
  int _attempts = 0;
  static const int _maxAttempts = 3;

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _pin =>
      _controllers.map((c) => c.text).join();

  Future<void> _verifyPin() async {
    if (_pin.length < 6) return;
    setState(() { _loading = true; _error = false; });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('utilisateurs')
          .doc(widget.uid)
          .get();

      final storedPin = doc.data()?['adminPin'] as String?;

      if (storedPin == null) {
        // Pas de PIN défini → accès refusé
        _showError('PIN admin non configuré. Contactez le super-admin.');
        return;
      }

      if (_pin == storedPin) {
        // PIN correct → continuer
        if (mounted) Navigator.pop(context, true);
      } else {
        _attempts++;
        if (_attempts >= _maxAttempts) {
          // Trop de tentatives → déconnexion
          if (mounted) {
            context.read<AuthBloc>().add(AuthSignOutRequested());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Trop de tentatives. Déconnexion.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        } else {
          _showError(
              'PIN incorrect. ${_maxAttempts - _attempts} tentative(s) restante(s)');
          _clearPin();
        }
      }
    } catch (e) {
      _showError('Erreur de vérification: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    setState(() => _error = true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _clearPin() {
    for (final c in _controllers) c.clear();
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône sécurité
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.admin_panel_settings_rounded,
                    color: Color(0xFFEF4444), size: 40),
              ),
              const SizedBox(height: 24),
              const Text('Vérification Admin',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text(
                'Entrez votre code PIN à 6 chiffres\npour accéder à l\'espace administrateur',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 40),

              // Champs PIN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  return Container(
                    width: 48,
                    height: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: _error
                            ? AppColors.error.withValues(alpha: 0.08)
                            : Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _error
                                ? AppColors.error
                                : AppColors.border,
                            width: _error ? 2 : 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFEF4444), width: 2),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty && i < 5) {
                          _focusNodes[i + 1].requestFocus();
                        }
                        if (val.isEmpty && i > 0) {
                          _focusNodes[i - 1].requestFocus();
                        }
                        if (_pin.length == 6) _verifyPin();
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Bouton vérifier
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _verifyPin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Text('Vérifier le PIN',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),

              // Annuler
              TextButton(
                onPressed: () =>
                    context.read<AuthBloc>().add(AuthSignOutRequested()),
                child: const Text('Annuler et se déconnecter',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),

              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.warning, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Le PIN admin est défini dans Firestore.\nChamp "adminPin" dans votre document utilisateur.',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
