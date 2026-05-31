// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AchievementModelAdapter extends TypeAdapter<AchievementModel> {
  @override
  final int typeId = 5;

  @override
  AchievementModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AchievementModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      icon: fields[4] as String,
      rarity: fields[5] as String,
      requirement: fields[6] as String,
      progress: fields[7] as int,
      target: fields[8] as int,
      isUnlocked: fields[9] as bool,
      unlockedAt: fields[10] as DateTime?,
      rewardType: fields[11] as String,
      rewardValue: fields[12] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AchievementModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.icon)
      ..writeByte(5)
      ..write(obj.rarity)
      ..writeByte(6)
      ..write(obj.requirement)
      ..writeByte(7)
      ..write(obj.progress)
      ..writeByte(8)
      ..write(obj.target)
      ..writeByte(9)
      ..write(obj.isUnlocked)
      ..writeByte(10)
      ..write(obj.unlockedAt)
      ..writeByte(11)
      ..write(obj.rewardType)
      ..writeByte(12)
      ..write(obj.rewardValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
