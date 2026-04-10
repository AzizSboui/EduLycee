import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/message.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/communication/communication_bloc.dart';
import '../../blocs/communication/communication_event.dart';
import '../../blocs/communication/communication_state.dart';
import '../../themes/app_theme.dart';
import '../../widgets/app_loading.dart';

// Contacts mock — en prod viendrait de Firestore
const _contacts = [
  _Contact(uid: 'eleve-001', nom: 'Lucas Dupont',   role: 'Élève',  icon: Icons.person_rounded,           color: Color(0xFF6366F1)),
  _Contact(uid: 'eleve-002', nom: 'Emma Martin',    role: 'Élève',  icon: Icons.person_rounded,           color: Color(0xFF6366F1)),
  _Contact(uid: 'parent-001', nom: 'Marie Dupont',  role: 'Parent', icon: Icons.family_restroom_rounded,  color: Color(0xFF10B981)),
  _Contact(uid: 'parent-002', nom: 'Jean Martin',   role: 'Parent', icon: Icons.family_restroom_rounded,  color: Color(0xFF10B981)),
  _Contact(uid: 'admin-001',  nom: 'Jean Bernard',  role: 'Admin',  icon: Icons.admin_panel_settings_rounded, color: Color(0xFFEF4444)),
];

class _Contact {
  final String uid;
  final String nom;
  final String role;
  final IconData icon;
  final Color color;
  const _Contact({
    required this.uid,
    required this.nom,
    required this.role,
    required this.icon,
    required this.color,
  });
}

class MessageriePage extends StatefulWidget {
  const MessageriePage({super.key});

  @override
  State<MessageriePage> createState() => _MessageriePageState();
}

class _MessageriePageState extends State<MessageriePage> {
  _Contact? _contactSelectionne;

  @override
  Widget build(BuildContext context) {
    if (_contactSelectionne == null) {
      return _ContactsList(onSelect: (c) {
        setState(() => _contactSelectionne = c);
        final authState = context.read<AuthBloc>().state;
        final myId = authState is AuthAuthenticated
            ? authState.utilisateur.uid
            : 'prof-001';
        context
            .read<CommunicationBloc>()
            .add(LoadConversation(myId, c.uid));
      });
    }

    return _ConversationView(
      contact: _contactSelectionne!,
      onBack: () => setState(() => _contactSelectionne = null),
    );
  }
}

// ── Liste des contacts ────────────────────────────────────────────────────────
class _ContactsList extends StatelessWidget {
  final ValueChanged<_Contact> onSelect;
  const _ContactsList({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    // Grouper par rôle
    final Map<String, List<_Contact>> grouped = {};
    for (final c in _contacts) {
      grouped.putIfAbsent(c.role, () => []).add(c);
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
                onTap: () => onSelect(c),
              )),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  final _Contact contact;
  final VoidCallback onTap;
  const _ContactTile({required this.contact, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
        leading: CircleAvatar(
          backgroundColor: contact.color.withValues(alpha: 0.15),
          child: Icon(contact.icon, color: contact.color, size: 20),
        ),
        title: Text(contact.nom,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        subtitle: Text(contact.role,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right,
            color: AppColors.textSecondary),
      ),
    );
  }
}

// ── Vue conversation ──────────────────────────────────────────────────────────
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
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    final authState = context.read<AuthBloc>().state;
    final myId = authState is AuthAuthenticated
        ? authState.utilisateur.uid
        : 'prof-001';

    final msg = Message(
      id: const Uuid().v4(),
      expediteurId: myId,
      destinataireId: widget.contact.uid,
      contenu: text,
      dateEnvoi: DateTime.now(),
      conversationId: '${myId}_${widget.contact.uid}',
    );

    context.read<CommunicationBloc>().add(SendMessage(msg));
    _ctrl.clear();

    // Recharger la conversation
    context
        .read<CommunicationBloc>()
        .add(LoadConversation(myId, widget.contact.uid));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final myId = authState is AuthAuthenticated
        ? authState.utilisateur.uid
        : 'prof-001';

    return Column(
      children: [
        // Header contact
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
                    Text(widget.contact.nom,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary)),
                    Text(widget.contact.role,
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
        // Messages
        Expanded(
          child: BlocBuilder<CommunicationBloc, CommunicationState>(
            builder: (context, state) {
              if (state is CommunicationLoading) return const AppLoading();

              final messages = state is ConversationLoaded
                  ? state.messages
                  : <Message>[];

              if (messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 48,
                          color: AppColors.textSecondary
                              .withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      Text(
                        'Démarrez la conversation\navec ${widget.contact.nom}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final msg = messages[i];
                  final isMe = msg.expediteurId == myId;
                  return _MessageBubble(message: msg, isMe: isMe);
                },
              );
            },
          ),
        ),
        // Champ saisie
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
                    hintStyle: const TextStyle(
                        color: AppColors.textHint),
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
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
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

// ── Bulle message ─────────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  const _MessageBubble({required this.message, required this.isMe});

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
            Text(
              message.contenu,
              style: TextStyle(
                  fontSize: 14,
                  color: isMe ? Colors.white : AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.dateEnvoi.hour.toString().padLeft(2, '0')}:${message.dateEnvoi.minute.toString().padLeft(2, '0')}',
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
