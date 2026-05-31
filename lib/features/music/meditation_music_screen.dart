import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:go_router/go_router.dart';

class _Track {
  final String id;
  final String title;
  final String artist;
  final String category;
  final String emoji;
  final Color color;
  final Duration duration;
  // Free-to-use audio URLs (loopable ambient tracks)
  final String url;

  const _Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.category,
    required this.emoji,
    required this.color,
    required this.duration,
    required this.url,
  });
}

class MeditationMusicScreen extends StatefulWidget {
  const MeditationMusicScreen({super.key});
  @override
  State<MeditationMusicScreen> createState() => _MeditationMusicScreenState();
}

class _MeditationMusicScreenState extends State<MeditationMusicScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  late AnimationController _waveController;

  int? _currentIndex;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 0.8;
  String? _error;
  String _selectedCategory = 'All';

  static const List<_Track> _tracks = [
    _Track(
      id: '1', title: 'Morning Calm', artist: 'Zen Garden',
      category: 'Focus', emoji: '🌅', color: Color(0xFFf77f00),
      duration: Duration(minutes: 10),
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    ),
    _Track(
      id: '2', title: 'Deep Sleep Waves', artist: 'Sleep Sounds',
      category: 'Sleep', emoji: '🌙', color: Color(0xFF3a0ca3),
      duration: Duration(minutes: 30),
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    ),
    _Track(
      id: '3', title: 'Forest Serenity', artist: 'Nature Sounds',
      category: 'Relaxation', emoji: '🌿', color: Color(0xFF38b000),
      duration: Duration(minutes: 20),
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    ),
    _Track(
      id: '4', title: 'Ocean Breath', artist: 'Calm Waves',
      category: 'Relaxation', emoji: '🌊', color: Color(0xFF00b4d8),
      duration: Duration(minutes: 15),
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
    ),
    _Track(
      id: '5', title: 'Focus Flow', artist: 'Mind Clarity',
      category: 'Focus', emoji: '🎯', color: Color(0xFF9d4edd),
      duration: Duration(minutes: 25),
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
    ),
    _Track(
      id: '6', title: 'Stress Release', artist: 'Calm Mind',
      category: 'Stress Relief', emoji: '💆', color: Color(0xFFf72585),
      duration: Duration(minutes: 12),
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
    ),
    _Track(
      id: '7', title: 'Energy Rise', artist: 'Vitality',
      category: 'Energy', emoji: '⚡', color: Color(0xFFffb700),
      duration: Duration(minutes: 8),
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
    ),
    _Track(
      id: '8', title: 'Gratitude Flow', artist: 'Heart Space',
      category: 'Meditation', emoji: '🙏', color: Color(0xFF4cc9f0),
      duration: Duration(minutes: 18),
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
    ),
  ];

  List<String> get _categories {
    final cats = ['All', ..._tracks.map((t) => t.category).toSet()];
    return cats;
  }

  List<_Track> get _filtered => _selectedCategory == 'All'
      ? _tracks
      : _tracks.where((t) => t.category == _selectedCategory).toList();

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _player.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.durationStream.listen((d) {
      if (mounted) setState(() => _duration = d ?? Duration.zero);
    });
    _player.playerStateStream.listen((s) {
      if (mounted) setState(() => _isPlaying = s.playing);
    });
  }

  Future<void> _playTrack(int index) async {
    final track = _filtered[index];
    setState(() { _isLoading = true; _error = null; });
    try {
      await _player.stop();
      await _player.setUrl(track.url);
      await _player.setVolume(_volume);
      await _player.play();
      setState(() { _currentIndex = index; _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; _error = 'Could not load track. Check your connection.'; });
    }
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> _playNext() async {
    if (_currentIndex == null) return;
    final next = (_currentIndex! + 1) % _filtered.length;
    await _playTrack(next);
  }

  Future<void> _playPrev() async {
    if (_currentIndex == null) return;
    final prev = (_currentIndex! - 1 + _filtered.length) % _filtered.length;
    await _playTrack(prev);
  }

  @override
  void dispose() {
    _player.dispose();
    _waveController.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentIndex != null ? _filtered[_currentIndex!] : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0a0a1a),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.canPop() ? context.pop() : context.go('/main'),
        ),
        title: const Text('Meditation Music',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          // Now playing player
          if (current != null) _buildPlayer(current),

          // Error banner
          if (_error != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12))),
                ],
              ),
            ),

          // Category filter
          _buildCategoryFilter(),

          // Track list
          Expanded(child: _buildTrackList()),
        ],
      ),
    );
  }

  Widget _buildPlayer(_Track track) {
    final progress = _duration.inSeconds > 0
        ? (_position.inSeconds / _duration.inSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [track.color.withOpacity(0.3), const Color(0xFF1a1a2e)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Track info row
          Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: track.color.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(track.emoji, style: const TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(track.title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                        overflow: TextOverflow.ellipsis),
                    Text(track.artist,
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  ],
                ),
              ),
              // Volume
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.volume_up, color: Colors.white54, size: 16),
                  SizedBox(
                    width: 70,
                    child: Slider(
                      value: _volume,
                      min: 0, max: 1,
                      activeColor: track.color,
                      inactiveColor: Colors.white12,
                      onChanged: (v) {
                        setState(() => _volume = v);
                        _player.setVolume(v);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress bar
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: track.color,
              inactiveTrackColor: Colors.white12,
              thumbColor: track.color,
              overlayColor: track.color.withOpacity(0.2),
            ),
            child: Slider(
              value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
              max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1,
              onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(_position), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                Text(_fmt(_duration), style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 28),
                onPressed: _playPrev,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _isLoading ? null : _togglePlay,
                child: Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: track.color,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: track.color.withOpacity(0.4), blurRadius: 12)],
                  ),
                  child: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 28),
                onPressed: _playNext,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final selected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() { _selectedCategory = cat; _currentIndex = null; }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF9d4edd) : const Color(0xFF1a1a2e),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? const Color(0xFF9d4edd) : Colors.white12,
                ),
              ),
              child: Center(
                child: Text(cat,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white54,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                    )),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrackList() {
    final tracks = _filtered;
    if (tracks.isEmpty) {
      return const Center(
        child: Text('No tracks in this category', style: TextStyle(color: Colors.white38)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: tracks.length,
      itemBuilder: (_, i) {
        final track = tracks[i];
        final isActive = _currentIndex == i;
        return GestureDetector(
          onTap: () => _playTrack(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isActive ? track.color.withOpacity(0.15) : const Color(0xFF1a1a2e),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive ? track.color.withOpacity(0.5) : Colors.white.withOpacity(0.06),
                width: isActive ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: track.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(track.emoji, style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(track.title,
                          style: TextStyle(
                            color: isActive ? track.color : Colors.white,
                            fontWeight: FontWeight.w700, fontSize: 14,
                          )),
                      const SizedBox(height: 2),
                      Text(track.artist,
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: track.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(track.category,
                          style: TextStyle(color: track.color, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 4),
                    Text(_fmt(track.duration),
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(
                  isActive && _isPlaying ? Icons.pause_circle : Icons.play_circle_outline,
                  color: isActive ? track.color : Colors.white24,
                  size: 28,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
