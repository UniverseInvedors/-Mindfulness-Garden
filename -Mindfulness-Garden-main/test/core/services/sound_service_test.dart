import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pranaverse/core/services/sound_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('xyz.luan/audioplayers.global'),
    (call) async => null,
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('xyz.luan/audioplayers'),
    (call) async => null,
  );

  test('initialize forces sound playback back on after being disabled', () async {
    final service = SoundService();

    await service.setEnabled(false);
    await service.setBgEnabled(false);

    await service.initialize();

    expect(service.enabled, isTrue);
    expect(service.bgEnabled, isTrue);
  });
}
