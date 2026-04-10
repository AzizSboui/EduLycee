import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../themes/app_theme.dart';
import '../../widgets/app_loading.dart';

class _Contact {
  final String uid;
  final String nom;
  final String prenom;
  final String role;
  const _Contact(
      {required this.uid,
      required this.nom,
      required this.prenom,
      required this.role});

  String get fullName => '$prenom $nom';

  IconData get icon {
    switch (role) {
      case 'professeur': return Icons.school_rounded;
      case 'admin':      return Icons.admin_panel_settings_rounded;
      case 'parent':     return Icons.family_restroom_rounded;
      default:           return Icons.person_rounded;
    }
  }

  Color get color {
    switch (role) {
      case 'professeur': return const Color(0xFFF59E0B);
      case 'admin':      return const Color(0xFFEF4444);
      case 'parent':     return const Color(0xFF10B981);
      default:           return const Color(0xFF6366F1);
    }
  }

  String get roleLabel {
    switch (role) {
      case 'professeur': return 'Professeur';
      case 'admin':      return 'Admin';
      case 'parent':     return 'Parent';
      default:           return 'Élève';
    }
  }
}

class MessagerieElevePage extends StatefulWidget {
  const MessagerieElevePage({super.key});

  @override
  State<MessagerieElevePage> createState() => _MessagerieElevePageState();
}

class _MessagerieElevePageState extends State<MessagerieElevePage> {
  _Contact? _contact;

  @override
  Widget build(BuildContext context) {
    if (_contact != null) {
      return _ConversationView(
        contact: _contact!,
        onBack: () => setState(() => _contact = null),
      );
    }
    return _ContactsList(
        onSelect: (c) => setState(() => _contact = c));
  }
}

class _ContactsList extends StatelessWidget {
  final ValueChanged<_Contact> onSelect;
  const _ContactsList({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final myId =
        authState is AuthAuthenticated ? authState.utilisateur.uid : '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const AppLoading();
        }

        final contacts = <_Contact>[];
        if (snap.hasData) {
          for (final doc in snap.data!.docs) {
            if (doc.id == myId) continue;
            final d = doc.data() as Map<String, dynamic>;
            final role = d['role'] ?? '';
            // L'élève peut contacter profs, admins et ses parents
            if (!['professeur', 'admin', 'parent'].contains(role)) continue;
            contacts.add(_Contact(
              uid: doc.id,
              nom: d['nom'] ?? '',
              prenom: d['prenom'] ?? '',
              role: role,
            ));
          }
        }

        if (contacts.isEmpty) {
          return const Center(
            child: Text('Aucun contact disponible',
                style: TextStyle(color: AppColors.textSecondary)),
          );
        }

        final Map<String, List<_Contact>> grouped = {};
        for (final c in contacts) {
          grouped.putIfAbsent(c.roleLabel, () => []).add(c);
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final entry in grouped.entries) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
                child: Text(entry.key,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5)),
              ),
              ...entry.value.map((c) => _ContactTile(
                    contact: c,
                    myId: myId,
                    onTap: () => onSelect(c),
                  )),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }
}

class _ContactTile extends StatelessWidget {
  final _Contact contact;
  final String myId;
  final VoidCallback onTap;
  const _ContactTile(
      {required this.contact, required this.myId, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .where('expediteurId', isEqualTo: contact.uid)
          .where('destinataireId', isEqualTo: myId)
          .where('lu', isEqualTo: false)
          .snapshots(),
      builder: (context, snap) {
        final unread = snap.data?.docs.length ?? 0;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: ListTile(
            onTap: onTap,
            leading: Stack(
              children: [
                CircleAvatar(
                  backgroundColor:
                      contact.color.withValues(alpha: 0.15),
                  child: Icon(contact.icon,
                      color: contact.color, size: 20),
                ),
                if (unread > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle),
                      child: Center(
                        child: Text('$unread',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(contact.fullName,
                style: TextStyle(
                    fontWeight: unread > 0
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: AppColors.textPrimary)),
            subtitle: Text(contact.roleLabel,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textSecondary),
          ),
        );
      },
    );
  }
}

class _ConversationView extends StatefulWidget {
  final _Contact contact;
  final VoidCallback onBack;
  const _ConversationView(
      {required this.contact, required this.onBack});

  @override
  State<_ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<_ConversationView> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  String get _myId {
    final s = context.read<AuthBloc>().state;
    return s is AuthAuthenticated ? s.utilisateur.uid : '';
  }

  String _convId(String a, String b) {
    final sorted = [a, b]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Future<void> _markAsRead() async {
    final myId = _myId;
    final snap = await FirebaseFirestore.instance
        .collection('messages')
        .where('expediteurId', isEqualTo: widget.contact.uid)
        .where('destinataireId', isEqualTo: myId)
        .where('lu', isEqualTo: false)
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'lu': true});
    }
    await batch.commit();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    final myId = _myId;
    final msgId = const Uuid().v4();
    await FirebaseFirestore.instance
        .collection('messages')
        .doc(msgId)
        .set({
      'id': msgId,
      'expediteurId': myId,
      'destinataireId': widget.contact.uid,
      'contenu': text,
      'dateEnvoi': FieldValue.serverTimestamp(),
      'lu': false,
      'conversationId': _convId(myId, widget.contact.uid),
    });
  }

  @override
  Widget build(BuildContext context) {
    final myId = _myId;
    final convId = _convId(myId, widget.contact.uid);

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18),
                onPressed: widget.onBack,
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    widget.contact.color.withValues(alpha: 0.15),
                child: Icon(widget.contact.icon,
                    color: widget.contact.color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.contact.fullName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary)),
                    Text(widget.contact.roleLabel,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('messages')
                .where('conversationId', isEqualTo: convId)
                .orderBy('dateEnvoi', descending: false)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const AppLoading();
              }
              final docs = snap.data?.docs ?? [];

              if (docs.isEmpty) {
                return Center(
                  child: Text(
                    'Démarrez la conversation\navec ${widget.contact.fullName}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 14),
                  ),
                );
              }

              _markAsRead();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollCtrl.hasClients) {
                  _scrollCtrl.animateTo(
                    _scrollCtrl.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  );
                }
              });

              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final d = docs[i].data() as Map<String, dynamic>;
                  final isMe = d['expediteurId'] == myId;
                  final ts = d['dateEnvoi'] as Timestamp?;
                  final date = ts?.toDate() ?? DateTime.now();
                  return _Bubble(
                      contenu: d['contenu'] ?? '',
                      isMe: isMe,
                      date: date);
                },
              );
            },
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: 'Écrire un message...',
                    hintStyle:
                        const TextStyle(color: AppColors.textHint),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  final String contenu;
  final bool isMe;
  final DateTime date;
  const _Bubble(
      {required this.contenu, required this.isMe, required this.date});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(contenu,
                style: TextStyle(
                    fontSize: 14,
                    color: isMe
                        ? Colors.white
                        : AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(
              '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                  fontSize: 10,
                  color: isMe
                      ? Colors.white60
                      : AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
