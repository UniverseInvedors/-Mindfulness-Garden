import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mindfulness_garden/presentation/providers/mood_provider.dart';
import 'package:mindfulness_garden/data/local_storage/local_storage_service.dart';
import 'package:mindfulness_garden/data/models/mood_model.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});
  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  static const List<Map<String, dynamic>> _moods = [
    {'emoji': '😢', 'label': 'Sad',     'color': Color(0xFF4361ee)},
    {'emoji': '😐', 'label': 'Neutral', 'color': Color(0xFF6c757d)},
    {'emoji': '🙂', 'label': 'Good',    'color': Color(0xFF38b000)},
    {'emoji': '😊', 'label': 'Happy',   'color': Color(0xFFffb700)},
    {'emoji': '😄', 'label': 'Great',   'color': Color(0xFFf77f00)},
    {'emoji': '🤩', 'label': 'Awesome', 'color': Color(0xFFf72585)},
  ];

  static const List<String> _tags = [
    'Work', 'Family', 'Health', 'Sleep', 'Exercise',
    'Social', 'Creative', 'Nature', 'Calm', 'Stressed',
  ];

  String _selectedMood = '';
  int _selectedRating = 3;
  final TextEditingController _noteController = TextEditingController();
  final List<String> _selectedTags = [];
  bool _isSaving = false;

  // Recent moods
  List<MoodModel> _recentMoods = [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  void _loadRecent() {
    final all = LocalStorageService.getAllMoods();
    all.sort((a, b) => b.date.compareTo(a.date));
    setState(() => _recentMoods = all.take(7).toList());
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedMood.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a mood first'),
          backgroundColor: Color(0xFFf72585),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await context.read<MoodProvider>().saveMood(
        mood: _selectedMood,
        rating: _selectedRating,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        tags: List.from(_selectedTags),
      );
      _loadRecent();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mood saved!'),
            backgroundColor: Color(0xFF38b000),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Reset form
        setState(() {
          _selectedMood = '';
          _selectedRating = 3;
          _selectedTags.clear();
          _noteController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0a0a1a),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.canPop() ? context.pop() : context.go('/main'),
        ),
        title: const Text('Mood Tracker',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00b4d8)))
                : const Text('Save',
                    style: TextStyle(color: Color(0xFF00b4d8), fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text('How are you feeling?',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Track your emotions to understand patterns',
                style: TextStyle(color: Color(0x80FFFFFF), fontSize: 14)),
            const SizedBox(height: 28),

            // Mood grid
            _buildMoodGrid(),
            const SizedBox(height: 28),

            // Rating
            _buildRating(),
            const SizedBox(height: 28),

            // Tags
            _buildTags(),
            const SizedBox(height: 28),

            // Notes — completely standalone, no theme
            _buildNotes(),
            const SizedBox(height: 28),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00b4d8),
                  disabledBackgroundColor: const Color(0x1AFFFFFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Save Mood Entry',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),

            // Recent moods
            if (_recentMoods.isNotEmpty) ...[
              const SizedBox(height: 32),
              _buildRecentMoods(),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Mood',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.15,
          ),
          itemCount: _moods.length,
          itemBuilder: (_, i) {
            final mood = _moods[i];
            final color = mood['color'] as Color;
            final selected = _selectedMood == mood['label'];
            return GestureDetector(
              onTap: () => setState(() => _selectedMood = mood['label'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selected ? Color.fromARGB(40, color.red, color.green, color.blue) : const Color(0xFF1a1a2e),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: selected ? color : const Color(0x1AFFFFFF), width: selected ? 2 : 1),
                  boxShadow: selected ? [BoxShadow(color: Color.fromARGB(60, color.red, color.green, color.blue), blurRadius: 10, offset: const Offset(0, 3))] : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(mood['emoji'] as String, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 6),
                    Text(mood['label'] as String,
                        style: TextStyle(
                          color: selected ? color : const Color(0xCCFFFFFF),
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        )),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Text('Intensity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFF9d4edd).withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Text('$_selectedRating / 5', style: const TextStyle(color: Color(0xFF9d4edd), fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ]),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(5, (i) {
            final r = i + 1;
            final active = r <= _selectedRating;
            return GestureDetector(
              onTap: () => setState(() => _selectedRating = r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF9d4edd) : const Color(0xFF1a1a2e),
                  shape: BoxShape.circle,
                  border: Border.all(color: active ? const Color(0xFF9d4edd) : const Color(0x33FFFFFF)),
                  boxShadow: active ? const [BoxShadow(color: Color(0x339d4edd), blurRadius: 8)] : null,
                ),
                child: Icon(active ? Icons.star_rounded : Icons.star_border_rounded,
                    color: active ? Colors.white : const Color(0x66FFFFFF), size: 22),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Low', style: TextStyle(color: Color(0x66FFFFFF), fontSize: 11)),
          const Text('High', style: TextStyle(color: Color(0x66FFFFFF), fontSize: 11)),
        ]),
      ],
    );
  }

  Widget _buildTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tags', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 4),
        const Text('What influenced your mood?', style: TextStyle(color: Color(0x66FFFFFF), fontSize: 12)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _tags.map((tag) {
            final selected = _selectedTags.contains(tag);
            return GestureDetector(
              onTap: () => setState(() => selected ? _selectedTags.remove(tag) : _selectedTags.add(tag)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF00b4d8) : const Color(0xFF1a1a2e),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selected ? const Color(0xFF00b4d8) : const Color(0x33FFFFFF)),
                ),
                child: Text(tag,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xB3FFFFFF),
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    )),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Notes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 4),
        const Text('Optional — add any thoughts or context', style: TextStyle(color: Color(0x66FFFFFF), fontSize: 12)),
        const SizedBox(height: 12),
        // Use a plain Container + TextField with NO theme inheritance
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x33FFFFFF)),
          ),
          child: Theme(
            // Override the entire InputDecorationTheme locally to prevent
            // the app-level theme from injecting floatingLabelStyle
            data: ThemeData(
              inputDecorationTheme: const InputDecorationTheme(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
                hintStyle: TextStyle(color: Color(0x4DFFFFFF), fontSize: 14),
                contentPadding: EdgeInsets.all(16),
              ),
              textSelectionTheme: const TextSelectionThemeData(
                cursorColor: Color(0xFF00b4d8),
              ),
            ),
            child: TextField(
              controller: _noteController,
              maxLines: 4,
              style: const TextStyle(color: Color(0xE6FFFFFF), fontSize: 14, height: 1.5),
              cursorColor: const Color(0xFF00b4d8),
              decoration: const InputDecoration(
                hintText: 'Add any thoughts or details...',
                hintStyle: TextStyle(color: Color(0x4DFFFFFF), fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentMoods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Moods', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 12),
        ..._recentMoods.map((m) {
          final moodData = _moods.firstWhere(
            (md) => md['label'] == m.mood,
            orElse: () => {'emoji': '😐', 'label': m.mood, 'color': const Color(0xFF6c757d)},
          );
          final color = moodData['color'] as Color;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a2e),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x1AFFFFFF)),
            ),
            child: Row(children: [
              Text(moodData['emoji'] as String, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.mood, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
                if (m.note != null && m.note!.isNotEmpty)
                  Text(m.note!, style: const TextStyle(color: Color(0x80FFFFFF), fontSize: 12),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Row(children: List.generate(m.rating.toInt(), (_) =>
                    const Icon(Icons.star_rounded, color: Color(0xFF9d4edd), size: 12))),
                const SizedBox(height: 2),
                Text(_formatDate(m.date), style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 11)),
              ]),
            ]),
          );
        }),
      ],
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${d.day}/${d.month}';
  }
}
