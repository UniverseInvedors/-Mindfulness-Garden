// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AiCoachScreen — personalised AI wellness coach powered by Zeno
// ─────────────────────────────────────────────────────────────────────────────

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_Msg> _messages = [
    const _Msg(
      text:
          "Hi! I'm Zeno, your personal mindfulness coach. 🌿\n\nHow are you feeling today? I can suggest a meditation, breathing exercise, or yoga flow — whatever your mind and body need right now.",
      isZeno: true,
    ),
  ];

  static const _quickPrompts = [
    "I'm stressed 😣",
    "Help me sleep 🌙",
    "I need energy ⚡",
    "Feeling anxious 💭",
    "Suggest a yoga flow 🏯",
    "Quick 5-min session 🕐",
  ];

  static const _responses = {
    "stressed":
        "I hear you. Let's start with a quick **Box Breathing** round — 4 counts in, hold 4, out 4, hold 4. It activates your parasympathetic nervous system and calms the stress response within minutes. Want me to guide you? 🌬️",
    "sleep":
        "A **4-7-8 breathing** session 20 minutes before bed is one of the most effective natural sleep aids. Pair it with our Night Garden scene for the best effect. Ready to start? 🌙",
    "energy":
        "Let's wake up your body with a **Sunrise Yoga Flow** — 10 minutes of sun salutations timed to uplifting music. Your garden gets a boost too! ☀️",
    "anxious":
        "Anxiety often lives in shallow breathing. Let's do **Diaphragmatic Breathing** — deep belly breaths that signal safety to your nervous system. I'll guide you through 5 rounds. 💙",
    "yoga":
        "Great choice! I recommend the **Zeno Mountain Flow** — a 15-minute session designed for deep presence. It blends gentle stretches with mindful breathing pauses. 🏯",
    "5-min":
        "Perfect for a busy day! Here's your plan: 2 min of **Breath Awareness**, followed by 3 min of **Body Scan Meditation**. Small but powerful. Let's go! 🕐",
  };

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_Msg(text: text.trim(), isZeno: false));
    });
    _ctrl.clear();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final lower = text.toLowerCase();
      String reply =
          "That's a great intention. I'm building your personalised plan now — let me check your recent mood and session data to tailor the perfect recommendation. 🌱";
      for (final key in _responses.keys) {
        if (lower.contains(key)) {
          reply = _responses[key]!;
          break;
        }
      }
      setState(() => _messages.add(_Msg(text: reply, isZeno: true)));
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
    Future.delayed(const Duration(milliseconds: 150), () {
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
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              colors.primary.withOpacity(0.10),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Header ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.canPop()
                          ? context.pop()
                          : context.go('/main'),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white.withOpacity(0.18)),
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colors.primary, colors.secondary],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🌿', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Zeno AI Coach',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800)),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text('Online · ready to guide you',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.55),
                                      fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/meditation'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: colors.primary.withOpacity(0.5)),
                        ),
                        child: Text('Start',
                            style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Quick-prompt chips ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 4),
                child: SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _quickPrompts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => _send(_quickPrompts[i]),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: colors.primary.withOpacity(0.40)),
                        ),
                        child: Text(_quickPrompts[i],
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.88),
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Messages ─────────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: _messages.length,
                  itemBuilder: (_, i) => _MessageBubble(msg: _messages[i]),
                ),
              ),

              // ── Input bar ─────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottom),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.09),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: colors.primary.withOpacity(0.40)),
                        ),
                        child: TextField(
                          controller: _ctrl,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Ask Zeno anything…',
                            hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.40),
                                fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                          ),
                          onSubmitted: _send,
                          textInputAction: TextInputAction.send,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _send(_ctrl.text),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colors.primary, colors.secondary],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withOpacity(0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
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

// ─────────────────────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.msg});
  final _Msg msg;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isZeno = msg.isZeno;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isZeno ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isZeno) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient:
                    LinearGradient(colors: [colors.primary, colors.secondary]),
                shape: BoxShape.circle,
              ),
              child: const Center(
                  child: Text('🌿', style: TextStyle(fontSize: 16))),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isZeno
                    ? colors.primary.withOpacity(0.18)
                    : Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isZeno ? Radius.zero : const Radius.circular(18),
                  bottomRight: isZeno ? const Radius.circular(18) : Radius.zero,
                ),
                border: Border.all(
                  color: isZeno
                      ? colors.primary.withOpacity(0.35)
                      : Colors.white.withOpacity(0.15),
                ),
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: SelectableText(
                msg.text,
                style: TextStyle(
                  color: Colors.white.withOpacity(isZeno ? 0.92 : 0.85),
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
            ),
          ),
          if (!isZeno) const SizedBox(width: 10),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Msg {
  const _Msg({required this.text, required this.isZeno});
  final String text;
  final bool isZeno;
}
