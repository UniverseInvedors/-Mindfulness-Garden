import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// Simple audio test - bypasses AudioManagerService to test raw audio
class SimpleAudioTest extends StatefulWidget {
  const SimpleAudioTest({super.key});

  @override
  State<SimpleAudioTest> createState() => _SimpleAudioTestState();
}

class _SimpleAudioTestState extends State<SimpleAudioTest> {
  final AudioPlayer _player = AudioPlayer();
  String _status = 'Ready to test';

  Future<void> _testSound() async {
    setState(() => _status = 'Testing button_click.mp3...');
    try {
      debugPrint('🔊 Attempting to play: sounds/button_click.mp3');
      await _player.play(AssetSource('sounds/button_click.mp3'));
      setState(() => _status = '✅ SUCCESS! Sound should play');
      debugPrint('✅ Audio played successfully');
    } catch (e) {
      setState(() => _status = '❌ ERROR: $e');
      debugPrint('❌ Error: $e');
    }
  }

  Future<void> _testMusic() async {
    setState(() => _status = 'Testing spring.mp3...');
    try {
      debugPrint('🎵 Attempting to play: music/spring.mp3');
      await _player.play(AssetSource('music/spring.mp3'));
      setState(() => _status = '✅ SUCCESS! Music should play');
      debugPrint('✅ Music played successfully');
    } catch (e) {
      setState(() => _status = '❌ ERROR: $e');
      debugPrint('❌ Error: $e');
    }
  }

  Future<void> _stopAudio() async {
    await _player.stop();
    setState(() => _status = 'Stopped');
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Audio Test'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _testSound,
                icon: const Icon(Icons.volume_up),
                label: const Text('Test Button Click Sound'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _testMusic,
                icon: const Icon(Icons.music_note),
                label: const Text('Test Background Music'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _stopAudio,
                icon: const Icon(Icons.stop),
                label: const Text('Stop Audio'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Check console for debug messages',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
