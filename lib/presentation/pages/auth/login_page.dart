import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../themes/app_theme.dart';
import 'register_page.dart';


const _roles = [
  _RoleInfo(label: 'Élève',      icon: Icons.person_rounded,              color: Color(0xFF6366F1), bg: Color(0xFFEEF2FF), hint: 'eleve@test.com'),
  _RoleInfo(label: 'Parent',     icon: Icons.family_restroom_rounded,     color: Color(0xFF10B981), bg: Color(0xFFECFDF5), hint: 'parent@test.com'),
  _RoleInfo(label: 'Professeur', icon: Icons.school_rounded,              color: Color(0xFFF59E0B), bg: Color(0xFFFFFBEB), hint: 'prof@test.com'),
  _RoleInfo(label: 'Admin',      icon: Icons.admin_panel_settings_rounded, color: Color(0xFFEF4444), bg: Color(0xFFFEF2F2), hint: 'admin@test.com'),
];
?
class _RoleInfo {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final String hint;
  const _RoleInfo({required this.label, required this.icon, required this.color, required this.bg, required this.hint});
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  int _selectedRole = 0;

  late final AnimationController _entryCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _entryCtrl.forward();
    _emailCtrl.text = _roles[0].hint;
    _passwordCtrl.text = '123456';
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _selectRole(int i) {
    setState(() => _selectedRole = i);
    _emailCtrl.text = _roles[i].hint;
    _passwordCtrl.text = '123456';
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthSignInRequested(_emailCtrl.text.trim(), _passwordCtrl.text),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = _roles[_selectedRole];
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text(state.message),
              ]),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ));
          }
        },
        child: Stack(
          children: [
            // ── Fond dégradé ──────────────────────────────────────────────
            Container(
              height: size.height * 0.42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E3A8A),
                    role.color.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            // ── Décorations géométriques ──────────────────────────────────
            Positioned(top: -50, right: -50,
              child: _Circle(size: 200, color: Colors.white.withValues(alpha: 0.04))),
            Positioned(top: 80, left: -30,
              child: _Circle(size: 140, color: role.color.withValues(alpha: 0.15))),
            Positioned(top: 30, right: 60,
              child: _Circle(size: 80, color: Colors.white.withValues(alpha: 0.06))),
            // Grille de points
            Positioned(
              top: 0, left: 0, right: 0,
              height: size.height * 0.42,
              child: CustomPaint(painter: _DotsPainter()),
            ),
            // ── Contenu ───────────────────────────────────────────────────
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 36),
                        _buildTopSection(role),
                        const SizedBox(height: 32),
                        _buildBottomCard(role),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section haute (logo + titre + rôles) ────────────────────────────────────
  Widget _buildTopSection(_RoleInfo role) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Logo
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.school_rounded, color: Color(0xFF1E3A8A), size: 36),
          ),
          const SizedBox(height: 14),
          const Text('EduLycée',
              style: TextStyle(
                  color: Colors.white, fontSize: 28,
                  fontWeight: FontWeight.w800, letterSpacing: -0.8)),
          const SizedBox(height: 4),
          Text('Espace ${role.label}',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14, fontWeight: FontWeight.w400)),
          const SizedBox(height: 28),
          // Sélecteur de rôle
          Row(
            children: List.generate(_roles.length, (i) {
              final r = _roles[i];
              final sel = _selectedRole == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _selectRole(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: sel ? Colors.white : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: sel ? Colors.white : Colors.white.withValues(alpha: 0.2),
                        width: sel ? 2 : 1,
                      ),
                      boxShadow: sel ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ] : [],
                    ),
                    child: Column(
                      children: [
                        Icon(r.icon,
                            color: sel ? r.color : Colors.white.withValues(alpha: 0.8),
                            size: 24),
                        const SizedBox(height: 5),
                        Text(r.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: sel ? r.color : Colors.white.withValues(alpha: 0.8),
                              letterSpacing: 0.3,
                            )),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Card formulaire ──────────────────────────────────────────────────────────
  Widget _buildBottomCard(_RoleInfo role) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 40,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: role.bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(role.icon, color: role.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Connexion',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.4)),
                        Text('Bienvenue, ${role.label}',
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  // Indicateur rôle actif
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: role.bg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(role.label,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: role.color)),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Champ email
              _buildFieldLabel('Adresse email'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: role.hint,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: role.bg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.alternate_email_rounded, color: role.color, size: 15),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: role.color, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFF),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (v) => v == null || !v.contains('@') ? 'Email invalide' : null,
              ),
              const SizedBox(height: 18),

              // Champ mot de passe
              _buildFieldLabel('Mot de passe'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: role.bg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.lock_outline_rounded, color: role.color, size: 15),
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary, size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: role.color, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFF),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (v) => v == null || v.length < 6 ? 'Minimum 6 caractères' : null,
              ),

              // Mot de passe oublié
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showResetDialog,
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8)),
                  child: Text('Mot de passe oublié ?',
                      style: TextStyle(color: role.color, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 4),

              // Bouton connexion
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final loading = state is AuthLoading;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: loading ? null : LinearGradient(
                        colors: [role.color, role.color.withValues(alpha: 0.75)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      color: loading ? const Color(0xFFE2E8F0) : null,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: loading ? [] : [
                        BoxShadow(
                          color: role.color.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: loading ? null : _submit,
                        borderRadius: BorderRadius.circular(14),
                        child: Center(
                          child: loading
                              ? SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                      color: role.color, strokeWidth: 2.5))
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(role.icon, color: Colors.white, size: 18),
                                    const SizedBox(width: 10),
                                    Text('Connexion ${role.label}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2)),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: Text('Mode démo — mot de passe : 123456',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                        fontStyle: FontStyle.italic)),
              ),
              const SizedBox(height: 12),
              // Lien vers inscription
              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const RegisterPage())),
                  icon: const Icon(Icons.person_add_outlined, size: 16),
                  label: const Text('Créer un nouveau compte'),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151)));
  }

  void _showResetDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Réinitialiser', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Entrez votre email.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 16),
            TextField(controller: ctrl,
                decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                context.read<AuthBloc>().add(AuthResetPasswordRequested(ctrl.text.trim()));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────
class _Circle extends StatelessWidget {
  final double size;
  final Color color;
  const _Circle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;
    const spacing = 24.0;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
