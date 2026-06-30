import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'dart:math';

enum _BrainwaveType { delta, theta, alpha, beta, gamma }

class _Preset {
  final String name;
  final String description;
  final _BrainwaveType type;
  final double beatHz;
  final Color color;
  final String emoji;
  final String benefit;
  final String url;
  const _Preset({
    required this.name, required this.description, required this.type,
    required this.beatHz, required this.color, required this.emoji,
    required this.benefit, required this.url,
  });
}

class BinauralBeatsScreen extends StatefulWidget {
  const BinauralBeatsScreen({super.key});
  @override
  State<BinauralBeatsScreen> createState() => _BinauralBeatsScreenState();
}

class _BinauralBeatsScreenState extends State<BinauralBeatsScreen>
    with TickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  late AnimationController _pulseController;
  late AnimationController _waveController;
  Timer? _timer;

  int _selectedIndex = 2; // default: Alpha
  bool _isPlaying = false;
  bool _isLoading = false;
  double _volume = 0.7;
  String? _error;
  int _elapsed = 0; // seconds
  final List<double> _wavePoints = List.filled(60, 0.5);

  static const List<_Preset> _presets = [
    _Preset(
      name: 'Deep Sleep', type: _BrainwaveType.delta, beatHz: 2.0,
      color: Color(0xFF3a0ca3), emoji: '😴',
      description: 'Delta waves (0.5–4 Hz)',
      benefit: 'Deep restorative sleep, healing, unconscious mind',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    ),
    _Preset(
      name: 'Relaxation', type: _BrainwaveType.theta, beatHz: 6.0,
      color: Color(0xFF4361ee), emoji: '🌊',
      description: 'Theta waves (4–8 Hz)',
      benefit: 'Deep relaxation, creativity, REM sleep, meditation',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    ),
    _Preset(
      name: 'Calm Focus', type: _BrainwaveType.alpha, beatHz: 10.0,
      color: Color(0xFF38b000), emoji: '🧘',
      description: 'Alpha waves (8–13 Hz)',
      benefit: 'Relaxed alertness, stress reduction, light meditation',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    ),
    _Preset(
      name: 'Sharp Focus', type: _BrainwaveType.beta, beatHz: 18.0,
      color: Color(0xFFf77f00), emoji: '🎯',
      description: 'Beta waves (13–30 Hz)',
      benefit: 'Concentration, problem solving, active thinking',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
    ),
    _Preset(
      name: 'Peak State', type: _BrainwaveType.gamma, beatHz: 40.0,
      color: Color(0xFFf72585), emoji: '⚡',
      description: 'Gamma waves (30–100 Hz)',
      benefit: 'Peak cognition, insight, high-level information processing',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
    ),
    _Preset(
      name: 'Creativity', type: _BrainwaveType.alpha, beatHz: 12.0,
      color: Color(0xFF9d4edd), emoji: '🎨',
      description: 'High Alpha waves (10–12 Hz)',
      benefit: 'Creative flow, artistic inspiration, open awareness',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _waveController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100))
      ..addListener(_updateWave)
      ..repeat();
    _player.playerStateStream.listen((s) {
      if (mounted) setState(() => _isPlaying = s.playing);
    });
  }

  void _updateWave() {
    if (!_isPlaying) return;
    final preset = _presets[_selectedIndex];
    final t = DateTime.now().millisecondsSinceEpoch / 1000.0;
    setState(() {
      for (int i = 0; i < _wavePoints.length; i++) {
        _wavePoints[i] = 0.5 + 0.4 * sin(t * preset.beatHz * 0.3 + i * 0.2);
      }
    });
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
      _timer?.cancel();
      return;
    }
    if (_player.processingState == ProcessingState.idle ||
        _player.processingState == ProcessingState.completed) {
      await _loadAndPlay();
    } else {
      await _player.play();
    }
    _startTimer();
  }

  Future<void> _loadAndPlay() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final preset = _presets[_selectedIndex];
      await _player.setUrl(preset.url);
      await _player.setVolume(_volume);
      await _player.setLoopMode(LoopMode.one);
      await _player.play();
      setState(() { _isLoading = false; _elapsed = 0; });
    } catch (e) {
      setState(() { _isLoading = false; _error = 'Could not load. Check your internet.'; });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _isPlaying) setState(() => _elapsed++);
    });
  }

  Future<void> _selectPreset(int index) async {
    if (_selectedIndex == index) return;
    final wasPlaying = _isPlaying;
    await _player.stop();
    _timer?.cancel();
    setState(() { _selectedIndex = index; _elapsed = 0; });
    if (wasPlaying) await _loadAndPlay();
  }

  String _fmtTime(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  void dispose() {
    _player.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preset = _presets[_selectedIndex];
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0a0a1a),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.canPop() ? context.pop() : context.go('/main'),
        ),
        title: const Text('Binaural Beats',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white54),
            onPressed: _showInfo,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Visualizer
            _buildVisualizer(preset),
            const SizedBox(height: 20),

            // Current preset info
            _buildPresetInfo(preset),
            const SizedBox(height: 20),

            // Error
            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.wifi_off, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12))),
                ]),
              ),

            // Controls
            _buildControls(preset),
            const SizedBox(height: 20),

            // Volume
            _buildVolumeControl(preset),
            const SizedBox(height: 20),

            // Preset grid
            _buildPresetGrid(),
            const SizedBox(height: 20),

            // Headphone reminder
            _buildHeadphoneNote(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualizer(_Preset preset) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) {
        final scale = _isPlaying ? 1.0 + _pulseController.value * 0.06 : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a2e),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: preset.color.withOpacity(0.3)),
              boxShadow: _isPlaying
                  ? [BoxShadow(color: preset.color.withOpacity(0.2), blurRadius: 20, spreadRadius: 2)]
                  : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CustomPaint(
                painter: _WavePainter(
                  points: _wavePoints,
                  color: preset.color,
                  isPlaying: _isPlaying,
                  beatHz: preset.beatHz,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(preset.emoji, style: const TextStyle(fontSize: 40)),
                      const SizedBox(height: 6),
                      Text('${preset.beatHz.toStringAsFixed(1)} Hz',
                          style: TextStyle(color: preset.color,
                              fontSize: 22, fontWeight: FontWeight.w800)),
                      Text(preset.description,
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                      if (_isPlaying) ...[
                        const SizedBox(height: 4),
                        Text(_fmtTime(_elapsed),
                            style: TextStyle(color: preset.color.withOpacity(0.8), fontSize: 13)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPresetInfo(_Preset preset) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: preset.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: preset.color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: preset.color.withOpacity(0.2), shape: BoxShape.circle),
            child: Center(child: Text(preset.emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(preset.name, style: TextStyle(color: preset.color,
                  fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 3),
              Text(preset.benefit,
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(_Preset preset) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Decrease Hz
        _controlBtn(Icons.remove, Colors.white54, () {
          final idx = (_selectedIndex - 1 + _presets.length) % _presets.length;
          _selectPreset(idx);
        }),
        const SizedBox(width: 20),
        // Play/Pause
        GestureDetector(
          onTap: _isLoading ? null : _togglePlay,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [preset.color, preset.color.withOpacity(0.6)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              boxShadow: [BoxShadow(color: preset.color.withOpacity(0.4), blurRadius: 16, spreadRadius: 2)],
            ),
            child: _isLoading
                ? const Padding(padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(width: 20),
        // Increase Hz
        _controlBtn(Icons.add, Colors.white54, () {
          final idx = (_selectedIndex + 1) % _presets.length;
          _selectPreset(idx);
        }),
      ],
    );
  }

  Widget _controlBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  Widget _buildVolumeControl(_Preset preset) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(children: [
        const Icon(Icons.headphones, color: Colors.white38, size: 18),
        const SizedBox(width: 8),
        const Text('Volume', style: TextStyle(color: Colors.white54, fontSize: 13)),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              activeTrackColor: preset.color,
              inactiveTrackColor: Colors.white12,
              thumbColor: preset.color,
              overlayColor: preset.color.withOpacity(0.2),
            ),
            child: Slider(value: _volume, min: 0, max: 1,
              onChanged: (v) { setState(() => _volume = v); _player.setVolume(v); }),
          ),
        ),
        Text('${(_volume * 100).toInt()}%',
            style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ]),
    );
  }

  Widget _buildPresetGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('BRAINWAVE STATES',
            style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.95),
          itemCount: _presets.length,
          itemBuilder: (_, i) {
            final p = _presets[i];
            final selected = _selectedIndex == i;
            return GestureDetector(
              onTap: () => _selectPreset(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selected ? Color.fromARGB(51, p.color.red, p.color.green, p.color.blue) : const Color(0xFF1a1a2e),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? p.color : const Color(0x12FFFFFF),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                    Text(p.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 3),
                    Text(p.name, textAlign: TextAlign.center,
                        style: TextStyle(color: selected ? p.color : Colors.white70,
                            fontSize: 10, fontWeight: selected ? FontWeight.w700 : FontWeight.normal),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 1),
                    Text('${p.beatHz.toStringAsFixed(0)} Hz',
                        style: TextStyle(color: Color.fromARGB(178, p.color.red, p.color.green, p.color.blue), fontSize: 9)),
                  ]),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeadphoneNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Row(children: [
        const Text('🎧', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Use Headphones', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w700, fontSize: 13)),
            Text('Binaural beats require stereo headphones to work. Each ear receives a slightly different frequency.',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
          ]),
        ),
      ]),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('How Binaural Beats Work', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: const Text(
          'When two slightly different frequencies are played in each ear, your brain perceives a third "beat" equal to the difference.\n\n'
          'Example: 200 Hz in left ear + 210 Hz in right ear = 10 Hz binaural beat (Alpha state).\n\n'
          'This entrains your brainwaves to the target frequency, inducing the associated mental state.\n\n'
          '• Delta (0.5–4 Hz): Deep sleep\n'
          '• Theta (4–8 Hz): Relaxation, creativity\n'
          '• Alpha (8–13 Hz): Calm focus\n'
          '• Beta (13–30 Hz): Active thinking\n'
          '• Gamma (30+ Hz): Peak cognition',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(color: Color(0xFF9d4edd))),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final List<double> points;
  final Color color;
  final bool isPlaying;
  final double beatHz;

  const _WavePainter({required this.points, required this.color,
      required this.isPlaying, required this.beatHz});

  @override
  void paint(Canvas canvas, Size size) {
    if (!isPlaying) {
      // Static idle wave
      final paint = Paint()
        ..color = color.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final path = Path();
      path.moveTo(0, size.height / 2);
      for (double x = 0; x <= size.width; x++) {
        path.lineTo(x, size.height / 2 + sin(x * 0.05) * 8);
      }
      canvas.drawPath(path, paint);
      return;
    }

    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    final step = size.width / (points.length - 1);

    path.moveTo(0, size.height * points[0]);
    fillPath.moveTo(0, size.height * points[0]);

    for (int i = 1; i < points.length; i++) {
      final x = i * step;
      final y = size.height * points[i];
      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter old) => true;
}
