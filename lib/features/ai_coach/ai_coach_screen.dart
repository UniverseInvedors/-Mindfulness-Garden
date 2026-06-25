import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pranaverse/core/services/ai_service.dart';

class _ChatMessage {
  final String text;
  final bool isUser;
  final List<_ActionButton>? actions;
  _ChatMessage({required this.text, required this.isUser, this.actions});
}

class _ActionButton {
  final String label;
  final String route;
  _ActionButton(this.label, this.route);
}

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});
  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final AiService _aiService = AiService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isLoading = true;
  String? _selectedMood;
  UserProfile? _profile;
  MeditationRecommendation? _currentRecommendation;
  bool _showHealthSetup = false;
  final List<String> _selectedConditions = [];
  String _selectedAge = '';
  String _selectedGoal = '';

  static const List<Map<String, String>> _moods = [
    {'emoji': '??', 'label': 'Happy'},
    {'emoji': '??', 'label': 'Stressed'},
    {'emoji': '??', 'label': 'Sad'},
    {'emoji': '??', 'label': 'Angry'},
    {'emoji': '??', 'label': 'Tired'},
    {'emoji': '??', 'label': 'Neutral'},
  ];

  static const List<String> _healthConditions = [
    'Anxiety', 'Depression', 'Insomnia', 'Chronic Stress',
    'High Blood Pressure', 'Chronic Pain', 'ADHD', 'PTSD',
    'Burnout', 'Grief', 'Panic Attacks', 'None of the above',
  ];

  static const List<String> _ageGroups = [
    'Under 18', '18–25', '26–35', '36–45', '46–55', '55+',
  ];

  static const List<String> _goals = [
    'Reduce stress & anxiety',
    'Sleep better',
    'Improve focus & productivity',
    'Manage emotions',
    'Build daily mindfulness habit',
    'Recover from burnout',
    'General wellbeing',
  ];

  final List<String> _quickReplies = [
    'I am feeling stressed',
    'Help me sleep better',
    'I need to focus',
    'I feel anxious',
    'What should I do today?',
    'I feel great today!',
  ];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);
    _profile = await _aiService.getUserProfile();
    final healthSet = _aiService.isHealthProfileSet;
    setState(() {
      _isLoading = false;
      _showHealthSetup = !healthSet;
    });
    if (!_showHealthSetup) {
      _buildRecommendation();
      Future.delayed(const Duration(milliseconds: 400), () => _sendWelcome());
    }
  }

  void _buildRecommendation() {
    if (_profile == null) return;
    final p = _profile!;
    final hour = DateTime.now().hour;
    final health = _aiService.getHealthProfile();
    final conditions = List<String>.from(health['conditions'] ?? []);
    final goal = health['goal'] as String? ?? '';
    MeditationType type;
    String reason;
    double confidence;
    String route;
    if (conditions.contains('Insomnia') || goal.contains('Sleep') || hour >= 21 || hour <= 5) {
      type = MeditationType.sleep;
      reason = conditions.contains('Insomnia') ? 'Based on your insomnia, sleep meditation calms your nervous system' : 'Evening — wind down for deep sleep';
      confidence = 0.94; route = '/breathing/478';
    } else if (conditions.contains('Anxiety') || conditions.contains('Panic Attacks') || conditions.contains('PTSD')) {
      type = MeditationType.breathAwareness;
      reason = 'For anxiety and panic, slow breath awareness is most effective';
      confidence = 0.92; route = '/breathing/awareness';
    } else if (conditions.contains('High Blood Pressure') || conditions.contains('Chronic Stress') || p.stressLevel > 70) {
      type = MeditationType.stressRelief;
      reason = p.stressLevel > 70 ? 'Elevated stress detected — box breathing will help' : 'For high blood pressure, box breathing lowers cortisol';
      confidence = 0.90; route = '/breathing/box';
    } else if (conditions.contains('ADHD') || goal.contains('focus') || goal.contains('productivity')) {
      type = MeditationType.breathAwareness;
      reason = 'For focus and ADHD, alternate nostril breathing sharpens concentration';
      confidence = 0.88; route = '/breathing/alternate';
    } else if (conditions.contains('Depression') || conditions.contains('Grief') || goal.contains('emotions')) {
      type = MeditationType.lovingKindness;
      reason = 'Loving-kindness meditation is clinically proven to lift mood';
      confidence = 0.89; route = '/breathing/awareness';
    } else if (conditions.contains('Burnout') || goal.contains('burnout')) {
      type = MeditationType.energyBoost;
      reason = 'For burnout, diaphragmatic breathing restores energy gently';
      confidence = 0.87; route = '/breathing/diaphragmatic';
    } else if (hour >= 6 && hour <= 9) {
      type = MeditationType.breathAwareness;
      reason = 'Morning breath awareness sets a calm, focused tone';
      confidence = 0.85; route = '/breathing/awareness';
    } else {
      type = MeditationType.breathAwareness;
      reason = 'Daily mindfulness keeps you grounded and resilient';
      confidence = 0.75; route = '/breathing';
    }
    setState(() => _currentRecommendation = MeditationRecommendation(
      type: type,
      duration: Duration(minutes: p.averageDuration.inMinutes > 0 ? p.averageDuration.inMinutes : 10),
      reason: reason, confidence: confidence, route: route,
    ));
  }

  void _sendWelcome() {
    if (!mounted || _profile == null) return;
    final p = _profile!;
    final health = _aiService.getHealthProfile();
    final conditions = List<String>.from(health['conditions'] ?? []);
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Neural link established. Good morning' : hour < 17 ? 'Neural link established. Good afternoon' : 'Neural link established. Good evening';
    String ctx = '';
    if (p.meditationStreak > 0) ctx += ' You are on a ${p.meditationStreak}-day streak!';
    if (p.sessionsToday > 0) ctx += ' ${p.sessionsToday} session${p.sessionsToday > 1 ? 's' : ''} completed today.';
    if (p.todayMood != null) ctx += ' ${p.todayMood!} mood signature detected.';
    String note = '';
    if (conditions.isNotEmpty && !conditions.contains('None of the above')) {
      note = ' Health matrix loaded (${conditions.take(2).join(', ')}) — protocols calibrated.';
    }
    _addBotMessage('$greeting, operative.$ctx$note\n\nI am ZENO — your neural mindfulness interface. How is your biometric state right now? Select a mood or transmit your thoughts.');
  }

  void _addBotMessage(String text, {List<_ActionButton>? actions}) {
    if (!mounted) return;
    setState(() => _messages.add(_ChatMessage(text: text, isUser: false, actions: actions)));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();
    setState(() { _messages.add(_ChatMessage(text: text, isUser: true)); _isTyping = true; });
    _scrollToBottom();
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _isTyping = false);
    final r = _generateResponse(text);
    _addBotMessage(r.text, actions: r.actions);
  }

  _ChatMessage _generateResponse(String input) {
    if (_profile == null) return _ChatMessage(text: 'Loading neural profile...', isUser: false);
    final lower = input.toLowerCase();
    final p = _profile!;
    final health = _aiService.getHealthProfile();
    final conditions = List<String>.from(health['conditions'] ?? []);

    if (lower.contains('stress') || lower.contains('anxious') || lower.contains('overwhelm') || lower.contains('anxiety') || lower.contains('panic') || lower.contains('worry')) {
      final extra = conditions.contains('Anxiety') || conditions.contains('Panic Attacks')
          ? '\n\nGiven your anxiety history, start with just 3 minutes of box breathing. Short sessions beat forcing long ones.'
          : conditions.contains('High Blood Pressure') ? '\n\nWith your blood pressure data, box breathing is critical — it activates the vagus nerve and lowers cortisol.' : '';
      return _ChatMessage(
        text: 'Signal received. Stress detected.$extra\n\nExecute now: inhale 4, hold 4, exhale 4. Repeat 3 cycles.\n\nStress index from mood logs: ${p.stressLevel.toInt()}/100. ${p.stressLevel > 70 ? "Elevated — initiating countermeasures." : "Within manageable range."}',
        isUser: false,
        actions: [_ActionButton('Box Breathing', '/breathing/box'), _ActionButton('Zeno Breathing', '/breathing/zeno')],
      );
    }
    if (lower.contains('sleep') || lower.contains('insomnia') || lower.contains('tired') || lower.contains("can't sleep") || lower.contains('wake up')) {
      final extra = conditions.contains('Insomnia') ? '\n\nFor chronic insomnia, deploy 4-7-8 every night at the same time — it retrains your nervous system over 2–3 weeks.' : '';
      return _ChatMessage(
        text: 'Sleep disruption detected.$extra\n\n4-7-8 protocol: inhale 4, hold 7, exhale 8. Extended exhale activates your parasympathetic system.\n\nOptimise: 18–20°C, no screens 30 min before shutdown, consistent sleep cycle.',
        isUser: false,
        actions: [_ActionButton('4-7-8 Breathing', '/breathing/478'), _ActionButton('Sleep Meditation', '/guided-meditation')],
      );
    }
    if (lower.contains('focus') || lower.contains('concentrate') || lower.contains('distract') || lower.contains('adhd') || lower.contains('productive')) {
      final extra = conditions.contains('ADHD') ? '\n\nFor ADHD, alternate nostril breathing synchronises both brain hemispheres and improves executive function.' : '';
      return _ChatMessage(
        text: 'Focus module activated.$extra\n\nBox breathing sharpens concentration in under 5 minutes. Elite operatives use it before high-stakes missions.\n\nProtocol: 25 min focused work ? 5 min mindful breathing ? repeat.',
        isUser: false,
        actions: [_ActionButton('Alternate Nostril', '/breathing/alternate'), _ActionButton('Box Breathing', '/breathing/box')],
      );
    }
    if (lower.contains('sad') || lower.contains('depress') || lower.contains('down') || lower.contains('hopeless') || lower.contains('grief') || lower.contains('lonely')) {
      final extra = conditions.contains('Depression') || conditions.contains('Grief') ? '\n\nWith depression in your profile, 5 minutes of loving-kindness daily shows measurable improvement. Start small — it compounds.' : '';
      return _ChatMessage(
        text: 'Emotional distress signal received.$extra\n\nGratitude practice is one of the most researched mood-lifters. Naming 3 small things shifts brain chemistry.\n\nMood signature: ${_getMoodTrendText(p)}.',
        isUser: false,
        actions: [_ActionButton('Loving-Kindness', '/breathing/awareness'), _ActionButton('Guided Meditation', '/guided-meditation')],
      );
    }
    if (lower.contains('angry') || lower.contains('frustrat') || lower.contains('mad') || lower.contains('irritat')) {
      return _ChatMessage(
        text: 'Anger signal detected — it means something matters to you.\n\nExecute: exhale slowly for 8 counts. This activates your parasympathetic system and gives your prefrontal cortex time to engage.\n\nDiaphragmatic breathing slows heart rate within 90 seconds.',
        isUser: false,
        actions: [_ActionButton('Diaphragmatic Breathing', '/breathing/diaphragmatic'), _ActionButton('Box Breathing', '/breathing/box')],
      );
    }
    if (lower.contains('happy') || lower.contains('great') || lower.contains('good') || lower.contains('amazing') || lower.contains('wonderful')) {
      return _ChatMessage(
        text: 'Positive biometric signature confirmed.\n\nPositive states are optimal for deepening practice. Meditation anchors this state and builds resilience.\n\nYou have logged ${p.totalSessions} sessions totalling ${p.totalMinutes} minutes. Keep building.',
        isUser: false,
        actions: [_ActionButton('Gratitude Practice', '/guided-meditation'), _ActionButton('Visit Garden', '/garden')],
      );
    }
    if (lower.contains('recommend') || lower.contains('suggest') || lower.contains('what should') || lower.contains('today')) {
      return _ChatMessage(
        text: _getPersonalisedRecommendation(p),
        isUser: false,
        actions: _currentRecommendation != null ? [_ActionButton('Start Recommended Session', _currentRecommendation!.route)] : null,
      );
    }
    if (lower.contains('burnout') || lower.contains('exhausted') || lower.contains('drained') || lower.contains('empty')) {
      return _ChatMessage(
        text: 'Burnout detected — your system needs recovery, not more output.\n\nDiaphragmatic breathing stimulates the vagus nerve and reduces cortisol without demanding anything from you.\n\nReduce session length. Even 3 minutes counts. Consistency beats duration.',
        isUser: false,
        actions: [_ActionButton('Diaphragmatic Breathing', '/breathing/diaphragmatic'), _ActionButton('Zeno Breathing', '/breathing/zeno')],
      );
    }
    if (lower.contains('pain') || lower.contains('hurt') || lower.contains('ache') || lower.contains('chronic')) {
      return _ChatMessage(
        text: 'Mindfulness-based breathing reduces chronic pain perception by up to 40%.\n\nBody scan meditation helps you observe pain without resistance, paradoxically reducing its intensity.\n\nInitiate with 5 minutes of diaphragmatic breathing.',
        isUser: false,
        actions: [_ActionButton('Diaphragmatic Breathing', '/breathing/diaphragmatic'), _ActionButton('Guided Meditation', '/guided-meditation')],
      );
    }
    if (lower.contains('breath') || lower.contains('exercise') || lower.contains('technique')) {
      return _ChatMessage(
        text: 'Neural database — optimal protocols:\n\n• Box Breathing — stress, focus, high BP\n• 4-7-8 — sleep, anxiety, panic\n• Zeno Breathing — general stress relief\n• Alternate Nostril — ADHD, balance, energy\n• Diaphragmatic — burnout, chronic pain, anger\n• Breath Awareness — anxiety, depression, beginners\n\nCalibrated for your profile: ${_getTopRecommendationName()}.',
        isUser: false,
        actions: [_ActionButton('All Exercises', '/breathing')],
      );
    }
    if (lower.contains('progress') || lower.contains('stats') || lower.contains('how am i') || lower.contains('streak')) {
      return _ChatMessage(
        text: 'Operative status report:\n\n?? Streak: ${p.meditationStreak} days\n?? Sessions: ${p.totalSessions}\n? Minutes: ${p.totalMinutes}\n?? Avg: ${p.averageDuration.inMinutes} min\n?? Mood: ${_getMoodTrendText(p)}\n?? Stress: ${p.stressLevel.toInt()}/100\n\n${_getProgressInsight(p)}',
        isUser: false,
        actions: [_ActionButton('View Full Progress', '/progress')],
      );
    }
    final defaults = [
      'Transmit more data. I want to give you the most targeted guidance based on your neural profile.',
      'Signal received. Based on your profile, a short breathing protocol could help right now. What feels most challenging?',
      'Acknowledged. How does your body feel — any tension, tightness, or system overload?',
      'Emotions and physical sensations are deeply linked. A body scan meditation might help you tune in. Initiating?',
    ];
    return _ChatMessage(text: defaults[DateTime.now().second % defaults.length], isUser: false);
  }

  String _getMoodTrendText(UserProfile p) {
    if (p.todayMoodRating == null) return 'no mood logged today';
    final r = p.todayMoodRating!;
    if (r >= 4) return 'positive (${r.toStringAsFixed(1)}/5)';
    if (r >= 3) return 'neutral (${r.toStringAsFixed(1)}/5)';
    return 'low (${r.toStringAsFixed(1)}/5) — initiating recovery protocol';
  }

  String _getProgressInsight(UserProfile p) {
    if (p.totalSessions == 0) return 'Begin your first mission today — even 3 minutes rewires neural pathways.';
    if (p.meditationStreak >= 7) return 'Incredible — 7+ day streak! Your nervous system is genuinely transforming.';
    if (p.meditationStreak >= 3) return 'Strong consistency! 3+ days builds real habit momentum.';
    if (p.stressLevel > 70) return 'Stress index elevated. Deploy at least one session today.';
    return 'Keep going — every session compounds toward lasting change.';
  }

  String _getPersonalisedRecommendation(UserProfile p) {
    final health = _aiService.getHealthProfile();
    final conditions = List<String>.from(health['conditions'] ?? []);
    final goal = health['goal'] as String? ?? '';
    final hour = DateTime.now().hour;
    final timeCtx = hour < 12 ? 'morning' : hour < 17 ? 'afternoon' : 'evening';
    String base = 'Neural analysis complete for this $timeCtx:\n\n';
    if (_currentRecommendation != null) {
      const names = {
        MeditationType.breathAwareness: 'Breath Awareness', MeditationType.bodyScan: 'Body Scan',
        MeditationType.lovingKindness: 'Loving-Kindness', MeditationType.gratitude: 'Gratitude Practice',
        MeditationType.stressRelief: 'Stress Relief', MeditationType.sleep: 'Sleep Meditation',
        MeditationType.energyBoost: 'Energy Boost',
      };
      base += '?? ${names[_currentRecommendation!.type]} (${_currentRecommendation!.duration.inMinutes} min)\n';
      base += '?? ${_currentRecommendation!.reason}\n';
      base += '? ${(_currentRecommendation!.confidence * 100).toInt()}% match for your profile';
    }
    if (conditions.isNotEmpty && !conditions.contains('None of the above')) base += '\n\nHealth matrix: ${conditions.join(', ')} — all protocols calibrated.';
    if (goal.isNotEmpty) base += '\n\nMission objective: $goal — you are on course.';
    return base;
  }

  String _getTopRecommendationName() {
    if (_currentRecommendation == null) return 'Breath Awareness';
    switch (_currentRecommendation!.type) {
      case MeditationType.sleep: return '4-7-8 Breathing';
      case MeditationType.stressRelief: return 'Box Breathing';
      case MeditationType.lovingKindness: return 'Loving-Kindness';
      case MeditationType.energyBoost: return 'Diaphragmatic Breathing';
      default: return 'Breath Awareness';
    }
  }

  @override
  void dispose() { _textController.dispose(); _scrollController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF050510),
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('?', style: TextStyle(fontSize: 48, color: Color(0xFF9d4edd))),
          SizedBox(height: 16),
          CircularProgressIndicator(color: Color(0xFF9d4edd)),
          SizedBox(height: 16),
          Text('INITIALISING NEURAL LINK...', style: TextStyle(color: Color(0x809d4edd), fontSize: 11, letterSpacing: 2)),
        ])),
      );
    }
    if (_showHealthSetup) return _buildHealthSetup();
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050510),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.canPop() ? context.pop() : context.go('/main')),
        title: const Text('ZENO · NEURAL INTERFACE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1.5)),
        actions: [
          if (_profile != null) IconButton(icon: const Icon(Icons.manage_accounts_outlined, color: Color(0xFF9d4edd)), onPressed: () => setState(() => _showHealthSetup = true)),
          if (_currentRecommendation != null) IconButton(icon: const Icon(Icons.auto_awesome, color: Color(0xFF00b4d8)), onPressed: _showRecommendation),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: const Color(0x1A9d4edd))),
      ),
      body: Column(children: [
        if (_selectedMood == null) _buildMoodSelector(),
        Expanded(child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: _messages.length + (_isTyping ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _messages.length) return _buildTypingIndicator();
            return _buildMessage(_messages[index]);
          },
        )),
        if (_messages.length <= 2) _buildQuickReplies(),
        _buildInputBar(),
      ]),
    );
  }

  Widget _buildHealthSetup() {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050510),
        elevation: 0,
        leading: _aiService.isHealthProfileSet ? IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => setState(() => _showHealthSetup = false)) : null,
        title: const Text('NEURAL PROFILE SETUP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 1.5, fontSize: 13)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: const Color(0x1A9d4edd))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Center(child: Text('?', style: TextStyle(fontSize: 64, color: Color(0xFF9d4edd)))),
          const SizedBox(height: 16),
          const Center(child: Text('CALIBRATE YOUR NEURAL MATRIX', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1))),
          const SizedBox(height: 8),
          const Center(child: Text('ZENO will personalise every protocol based on your biometric profile and mission objectives.', style: TextStyle(color: Color(0x99FFFFFF), fontSize: 13), textAlign: TextAlign.center)),
          const SizedBox(height: 32),
          _setupLabel('AGE BRACKET'),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: _ageGroups.map((a) => _chip(a, _selectedAge == a, () => setState(() => _selectedAge = a))).toList()),
          const SizedBox(height: 24),
          _setupLabel('PRIMARY MISSION OBJECTIVE'),
          const SizedBox(height: 10),
          ..._goals.map((g) => _radioTile(g, _selectedGoal == g, () => setState(() => _selectedGoal = g))),
          const SizedBox(height: 24),
          _setupLabel('HEALTH CONDITIONS'),
          const SizedBox(height: 4),
          const Text('Enables ZENO to deliver safe, targeted protocols.', style: TextStyle(color: Color(0x66FFFFFF), fontSize: 12)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: _healthConditions.map((c) => _chip(c, _selectedConditions.contains(c), () => setState(() {
            if (c == 'None of the above') { _selectedConditions.clear(); _selectedConditions.add(c); }
            else { _selectedConditions.remove('None of the above'); _selectedConditions.contains(c) ? _selectedConditions.remove(c) : _selectedConditions.add(c); }
          }))).toList()),
          const SizedBox(height: 32),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: (_selectedAge.isNotEmpty && _selectedGoal.isNotEmpty) ? _saveHealthProfile : null,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9d4edd), disabledBackgroundColor: const Color(0x1AFFFFFF), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Text('INITIALISE COACHING PROTOCOL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1)),
          )),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _setupLabel(String t) => Text(t, style: const TextStyle(color: Color(0xFF00b4d8), fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.5));

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF9d4edd) : const Color(0xFF0D0D1F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? const Color(0xFF9d4edd) : const Color(0x33FFFFFF)),
      ),
      child: Text(label, style: TextStyle(color: selected ? Colors.white : const Color(0xB3FFFFFF), fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
    ));
  }

  Widget _radioTile(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? const Color(0x269d4edd) : const Color(0xFF0D0D1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? const Color(0xFF9d4edd) : const Color(0x1AFFFFFF)),
      ),
      child: Row(children: [
        Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: selected ? const Color(0xFF9d4edd) : const Color(0x66FFFFFF), size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: TextStyle(color: selected ? Colors.white : const Color(0xB3FFFFFF), fontSize: 14, fontWeight: selected ? FontWeight.w600 : FontWeight.normal))),
      ]),
    ));
  }

  Future<void> _saveHealthProfile() async {
    await _aiService.saveHealthProfile(age: _selectedAge, goal: _selectedGoal, conditions: _selectedConditions);
    _profile = await _aiService.getUserProfile();
    _buildRecommendation();
    setState(() => _showHealthSetup = false);
    if (_messages.isEmpty) { Future.delayed(const Duration(milliseconds: 300), () => _sendWelcome()); }
    else { _addBotMessage('Neural profile updated. All protocols calibrated to your health matrix.'); }
  }

  Widget _buildMoodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Color(0xFF0D0D1F), border: Border(bottom: BorderSide(color: Color(0x1A9d4edd)))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('BIOMETRIC MOOD SCAN', style: TextStyle(color: Color(0x8000b4d8), fontSize: 10, letterSpacing: 2)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: _moods.map((mood) => GestureDetector(
          onTap: () { setState(() => _selectedMood = mood['label']); _sendMessage('I am feeling ${mood['label']} today'); },
          child: Column(children: [
            Text(mood['emoji']!, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 2),
            Text(mood['label']!, style: const TextStyle(color: Color(0x8000b4d8), fontSize: 10)),
          ]),
        )).toList()),
      ]),
    );
  }

  Widget _buildMessage(_ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (!msg.isUser) ...[
            Container(width: 30, height: 30, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF9d4edd), Color(0xFF00b4d8)]), shape: BoxShape.circle),
              child: const Center(child: Text('?', style: TextStyle(fontSize: 14, color: Colors.white)))),
            const SizedBox(width: 8),
          ],
          Flexible(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: msg.isUser ? const Color(0xFF00b4d8) : const Color(0xFF0D0D1F),
              borderRadius: BorderRadius.only(topLeft: const Radius.circular(18), topRight: const Radius.circular(18), bottomLeft: Radius.circular(msg.isUser ? 18 : 4), bottomRight: Radius.circular(msg.isUser ? 4 : 18)),
              border: msg.isUser ? null : const Border.fromBorderSide(BorderSide(color: Color(0x1A9d4edd))),
              boxShadow: msg.isUser ? const [BoxShadow(color: Color(0x3300b4d8), blurRadius: 8, offset: Offset(0, 2))] : null,
            ),
            child: Text(msg.text, style: const TextStyle(color: Color(0xE6FFFFFF), fontSize: 14, height: 1.5)),
          )),
          if (msg.isUser) const SizedBox(width: 8),
        ]),
        if (msg.actions != null && msg.actions!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.only(left: 38), child: Wrap(spacing: 8, runSpacing: 6, children: msg.actions!.map((a) => GestureDetector(
            onTap: () => context.push(a.route),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF9d4edd), Color(0xFF00b4d8)]), borderRadius: BorderRadius.all(Radius.circular(20)), boxShadow: [BoxShadow(color: Color(0x339d4edd), blurRadius: 8, offset: Offset(0, 2))]),
              child: Text(a.label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            ),
          )).toList())),
        ],
      ]),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
      Container(width: 30, height: 30, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF9d4edd), Color(0xFF00b4d8)]), shape: BoxShape.circle),
        child: const Center(child: Text('?', style: TextStyle(fontSize: 14, color: Colors.white)))),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: const BoxDecoration(color: Color(0xFF0D0D1F), borderRadius: BorderRadius.all(Radius.circular(18)), border: Border.fromBorderSide(BorderSide(color: Color(0x1A9d4edd)))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0x4D9d4edd), shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0x809d4edd), shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF9d4edd), shape: BoxShape.circle)),
        ]),
      ),
    ]));
  }

  Widget _buildQuickReplies() {
    return SizedBox(height: 44, child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _quickReplies.length,
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => _sendMessage(_quickReplies[i]),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: const BoxDecoration(color: Color(0xFF0D0D1F), borderRadius: BorderRadius.all(Radius.circular(20)), border: Border.fromBorderSide(BorderSide(color: Color(0x6600b4d8)))),
          child: Text(_quickReplies[i], style: const TextStyle(color: Color(0xFF00b4d8), fontSize: 12)),
        ),
      ),
    ));
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(color: Color(0xFF050510), border: Border(top: BorderSide(color: Color(0x1A9d4edd)))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: TextField(
          controller: _textController,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Transmit to ZENO...',
            hintStyle: const TextStyle(color: Color(0x4DFFFFFF), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFF0D0D1F),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: Color(0x339d4edd))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: Color(0xFF9d4edd), width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onSubmitted: _sendMessage,
          minLines: 1,
          maxLines: 5,
        )),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _sendMessage(_textController.text),
          child: Container(width: 46, height: 46,
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF9d4edd), Color(0xFF00b4d8)]), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x669d4edd), blurRadius: 12, offset: Offset(0, 2))]),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 20)),
        ),
      ]),
    );
  }

  void _showRecommendation() {
    final rec = _currentRecommendation!;
    const names = {
      MeditationType.breathAwareness: 'Breath Awareness', MeditationType.bodyScan: 'Body Scan',
      MeditationType.lovingKindness: 'Loving-Kindness', MeditationType.gratitude: 'Gratitude Practice',
      MeditationType.stressRelief: 'Stress Relief', MeditationType.sleep: 'Sleep Meditation',
      MeditationType.energyBoost: 'Energy Boost',
    };
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D0D1F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) => Container(
        decoration: const BoxDecoration(color: Color(0xFF0D0D1F), borderRadius: BorderRadius.vertical(top: Radius.circular(25)), border: Border(top: BorderSide(color: Color(0x339d4edd)))),
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.auto_awesome, color: Color(0xFF00b4d8)),
            const SizedBox(width: 8),
            const Text('ZENO RECOMMENDS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 1)),
            const Spacer(),
            Text('${(rec.confidence * 100).toInt()}% MATCH', style: const TextStyle(color: Color(0x8000b4d8), fontSize: 11, letterSpacing: 1)),
          ]),
          const SizedBox(height: 16),
          Text(names[rec.type] ?? 'Meditation', style: const TextStyle(color: Color(0xFF9d4edd), fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('${rec.duration.inMinutes} minutes', style: const TextStyle(color: Color(0x8000b4d8))),
          const SizedBox(height: 8),
          Text(rec.reason, style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 14)),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () { Navigator.pop(context); context.push(rec.route); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9d4edd), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text('INITIATE SESSION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 1)),
          )),
        ]),
      ),
    );
  }
}
