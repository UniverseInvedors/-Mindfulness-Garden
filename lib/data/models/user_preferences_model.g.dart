// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreferencesAdapter extends TypeAdapter<UserPreferences> {
  @override
  final int typeId = 4;

  @override
  UserPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferences(
      theme: fields[0] as String,
      notifications: fields[1] as bool,
      sounds: fields[2] as bool,
      vibration: fields[3] as bool,
      hapticFeedback: fields[4] as bool,
      autoPlayMusic: fields[5] as bool,
      defaultSessionDuration: fields[6] as int,
      defaultBreathingTechnique: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferences obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.theme)
      ..writeByte(1)
      ..write(obj.notifications)
      ..writeByte(2)
      ..write(obj.sounds)
      ..writeByte(3)
      ..write(obj.vibration)
      ..writeByte(4)
      ..write(obj.hapticFeedback)
      ..writeByte(5)
      ..write(obj.autoPlayMusic)
      ..writeByte(6)
      ..write(obj.defaultSessionDuration)
      ..writeByte(7)
      ..write(obj.defaultBreathingTechnique);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserPreferencesAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}
