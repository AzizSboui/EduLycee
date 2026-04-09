import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../themes/app_theme.dart';

const _roles = [
  _RoleInfo(label: 'Élève',      value: 'eleve',      icon: Icons.person_rounded,               color: Color(0xFF6366F1)),
  _RoleInfo(label: 'Parent',     value: 'parent',     icon: Icons.family_restroom_rounded,      color: Color(0xFF10B981)),
  _RoleInfo(label: 'Professeur', value: 'professeur', icon: Icons.school_rounded,               color: Color(0xFFF59E0B)),
  _RoleInfo(label: 'Admin',      value: 'admin',      icon: Icons.admin_panel_settings_rounded, color: Color(0xFFEF4444)),
];

class _RoleInfo {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _RoleInfo({required this.label, required this.value, required this.icon, required this.color});
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey    = GlobalKey<FormState>();
  final _nomCtrl    = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  int  _roleIndex   = 0;
  bool _obscure     = true;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final role = _roles[_roleIndex];
    context.read<AuthBloc>().add(AuthSignUpRequested(
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text,
      nom:      _nomCtrl.text.trim(),
      prenom:   _prenomCtrl.text.trim(),
      role:     role.value,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final role = _roles[_roleIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Créer un compte'),
        elevation: 0,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated || state is AuthSignUpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Compte ${role.label} créé avec succès ✅'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.all(16),
              ),
            );
            Navigator.pop(context);
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Sélecteur rôle ─────────────────────────────────
                const Text('Je suis…',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(_roles.length, (i) {
                    final r   = _roles[i];
                    final sel = _roleIndex == i;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _roleIndex = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: sel ? r.color : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: sel ? r.color : AppColors.border),
                            boxShadow: sel
                                ? [BoxShadow(
                                    color: r.color.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4))]
                                : [],
                          ),
                          child: Column(
                            children: [
                              Icon(r.icon,
                                  color: sel ? Colors.white : r.color,
                                  size: 24),
                              const SizedBox(height: 5),
                              Text(r.label,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: sel ? Colors.white : r.color)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // ── Formulaire ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: role.color.withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                          color: role.color.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    children: [
                      // Prénom + Nom
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _prenomCtrl,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Prénom',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Requis' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _nomCtrl,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Nom',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Requis' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) => v == null || !v.contains('@')
                            ? 'Email invalide'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Mot de passe
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => v == null || v.length < 6
                            ? 'Minimum 6 caractères'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Info rôle
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: role.color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(role.icon, color: role.color, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Rôle : ${role.label} (${role.value})',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: role.color),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Bouton créer ────────────────────────────────────
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final loading = state is AuthLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: role.color,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: loading
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(role.icon,
                                      color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Créer compte ${role.label}',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
