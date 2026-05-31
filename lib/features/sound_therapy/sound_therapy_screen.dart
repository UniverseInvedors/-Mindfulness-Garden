import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';

class _Sound {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final Color color;
  final String url;
  const _Sound({required this.id, required this.name, required this.description,
      required this.emoji, required this.color, required this.url});
}

class SoundTherapyScreen extends StatefulWidget {
  const SoundTherapyScreen({super.key});
  @override
  State<SoundTherapyScreen> createState() => _SoundTherapyScreenState();
}

class _SoundTherapyScreenState extends State<SoundTherapyScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  late AnimationController _waveController;
  String? _activeId;
  bool _isPlaying = false;
  bool _isLoading = false;
  double _volume = 0.7;
  String? _error;

  static const List<_Sound> _sounds = [
    _Sound(id: 'ocean', name: 'Ocean Waves', description: 'Calming ocean for deep relaxation',
        emoji: '🌊', color: Color(0xFF00b4d8),
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'),
    _Sound(id: 'rain', name: 'Gentle Rain', description: 'Soft rain for focus and sleep',
        emoji: '🌧', color: Color(0xFF4361ee),
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'),
    _Sound(id: 'forest', name: 'Forest Birds', description: 'Peaceful forest ambiance',
        emoji: '🌿', color: Color(0xFF38b000),
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'),
    _Sound(id: 'bowl', name: 'Singing Bowl', description: 'Tibetan bowl frequencies',
        emoji: '🔔', color: Color(0xFFf77f00),
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3'),
    _Sound(id: 'white', name: 'White Noise', description: 'Block distractions completely',
        emoji: '📻', color: Color(0xFF6c757d),
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3'),
    _Sound(id: 'piano', name: 'Calm Piano', description: 'Soothing piano melodies',
        emoji: '🎹', color: Color(0xFF9d4edd),
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3'),
    _Sound(id: 'fire', name: 'Crackling Fire', description: 'Warm fireplace ambiance',
        emoji: '🔥', color: Color(0xFFd62828),
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3'),
    _Sound(id: 'wind', name: 'Mountain Wind', description: 'Gentle breeze through trees',
        emoji: '💨', color: Color(0xFF4cc9f0),
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3'),
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _player.playerStateStream.listen((s) {
      if (mounted) setState(() => _isPlaying = s.playing);
    });
  }

  Future<void> _toggle(String id) async {
    if (_activeId == id) {
      _isPlaying ? await _player.pause() : await _player.play();
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      final sound = _sounds.firstWhere((s) => s.id == id);
      await _player.stop();
      await _player.setUrl(sound.url);
      await _player.setVolume(_volume);
      await _player.setLoopMode(LoopMode.one);
      await _player.play();
      setState(() { _activeId = id; _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; _error = 'Could not load. Check your internet connection.'; });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeId != null ? _sounds.firstWhere((s) => s.id == _activeId) : null;
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0a0a1a),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.canPop() ? context.pop() : context.go('/main'),
        ),
        title: const Text('Sound Therapy',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          if (active != null) _buildNowPlaying(active),
          if (_error != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.wifi_off, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12))),
              ]),
            ),
          _buildVolumeBar(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.05),
              itemCount: _sounds.length,
              itemBuilder: (_, i) => _buildCard(_sounds[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlaying(_Sound sound) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (_, __) => Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [sound.color.withOpacity(0.3), sound.color.withOpacity(0.1)]),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: sound.color.withOpacity(0.4)),
        ),
        child: Row(children: [
          Transform.scale(scale: 1.0 + _waveController.value * 0.08,
              child: Text(sound.emoji, style: const TextStyle(fontSize: 32))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('NOW PLAYING', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.5)),
            Text(sound.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
            Text(sound.description, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                overflow: TextOverflow.ellipsis),
          ])),
          Row(children: List.generate(4, (i) {
            final h = 6.0 + sin(_waveController.value * pi * 2 + i) * 7;
            return Container(margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 3, height: h.abs() + 4,
                decoration: BoxDecoration(color: sound.color, borderRadius: BorderRadius.circular(2)));
          })),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _toggle(sound.id),
            child: Container(width: 38, height: 38,
              decoration: BoxDecoration(color: sound.color.withOpacity(0.3), shape: BoxShape.circle),
              child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white, size: 20)),
          ),
        ]),
      ),
    );
  }

  Widget _buildVolumeBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(children: [
        const Icon(Icons.volume_down, color: Colors.white38, size: 18),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              activeTrackColor: const Color(0xFF9d4edd),
              inactiveTrackColor: Colors.white12,
              thumbColor: const Color(0xFF9d4edd),
              overlayColor: const Color(0x229d4edd),
            ),
            child: Slider(value: _volume, min: 0, max: 1,
              onChanged: (v) { setState(() => _volume = v); _player.setVolume(v); }),
          ),
        ),
        const Icon(Icons.volume_up, color: Colors.white38, size: 18),
        const SizedBox(width: 6),
        Text('${(_volume * 100).toInt()}%', style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ]),
    );
  }

  Widget _buildCard(_Sound sound) {
    final isActive = _activeId == sound.id;
    return GestureDetector(
      onTap: () => _toggle(sound.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isActive
                ? [sound.color.withOpacity(0.45), sound.color.withOpacity(0.15)]
                : [const Color(0xFF1a1a2e), const Color(0xFF1a1a2e)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? sound.color.withOpacity(0.6) : Colors.white.withOpacity(0.07),
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: sound.color.withOpacity(0.2), blurRadius: 14, offset: const Offset(0, 4))]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(sound.emoji, style: const TextStyle(fontSize: 26)),
              const Spacer(),
              if (isActive)
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (_, __) => Row(children: List.generate(3, (i) {
                    final h = 5.0 + sin(_waveController.value * pi * 2 + i * 1.2) * 5;
                    return Container(margin: const EdgeInsets.symmetric(horizontal: 1),
                        width: 3, height: h.abs() + 3,
                        decoration: BoxDecoration(color: sound.color, borderRadius: BorderRadius.circular(2)));
                  })),
                )
              else
                Icon(Icons.play_circle_outline, color: Colors.white.withOpacity(0.25), size: 20),
            ]),
            const SizedBox(height: 8),
            Text(sound.name, style: TextStyle(
                color: isActive ? Colors.white : Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 3),
            Text(sound.description, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isActive ? sound.color.withOpacity(0.25) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(isActive && _isPlaying ? '● Playing' : '∞ Loop',
                  style: TextStyle(color: isActive ? sound.color : Colors.white38,
                      fontSize: 10, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      ),
    );
  }
}
