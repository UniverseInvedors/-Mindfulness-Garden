// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionModelAdapter extends TypeAdapter<SessionModel> {
  @override
  final int typeId = 3;

  @override
  SessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionModel(
      id: fields[0] as String,
      startTime: fields[1] as DateTime,
      durationMinutes: fields[2] as int,
      meditationType: fields[3] as String,
      focusArea: fields[4] as String,
      initialHeartRate: fields[5] as int,
      finalHeartRate: fields[6] as int,
      moodBefore: fields[7] as String,
      moodAfter: fields[8] as String,
      notes: fields[9] as String?,
      soundsUsed: (fields[10] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SessionModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.durationMinutes)
      ..writeByte(3)
      ..write(obj.meditationType)
      ..writeByte(4)
      ..write(obj.focusArea)
      ..writeByte(5)
      ..write(obj.initialHeartRate)
      ..writeByte(6)
      ..write(obj.finalHeartRate)
      ..writeByte(7)
      ..write(obj.moodBefore)
      ..writeByte(8)
      ..write(obj.moodAfter)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.soundsUsed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
