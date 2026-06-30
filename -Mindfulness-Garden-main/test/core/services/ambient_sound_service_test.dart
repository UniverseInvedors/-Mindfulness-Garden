import 'package:flutter_test/flutter_test.dart';
import 'package:pranaverse/core/services/ambient_sound_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AmbientSoundService weather mapping', () {
    test('maps weather types to matching ambient sound assets', () {
      final service = AmbientSoundService();

      expect(service.getWeatherSoundPath('sunny'), 'music/summer.mp3');
      expect(service.getWeatherSoundPath('cloudy'), 'music/spring.mp3');
      expect(service.getWeatherSoundPath('rainy'), 'music/rainny.mp3');
      expect(service.getWeatherSoundPath('snowy'), 'music/winter.mp3');
      expect(service.getWeatherSoundPath('stormy'), 'music/rainny.mp3');
    });
  });
}
