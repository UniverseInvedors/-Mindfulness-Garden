// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_track_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MusicTrackModelAdapter extends TypeAdapter<MusicTrackModel> {
  @override
  final int typeId = 6;

  @override
  MusicTrackModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MusicTrackModel(
      id: fields[0] as String,
      title: fields[1] as String,
      artist: fields[2] as String,
      category: fields[3] as String,
      audioUrl: fields[4] as String,
      imageUrl: fields[5] as String,
      duration: fields[6] as int,
      isFavorite: fields[7] as bool,
      lastPlayed: fields[8] as DateTime?,
      playCount: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MusicTrackModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.audioUrl)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.duration)
      ..writeByte(7)
      ..write(obj.isFavorite)
      ..writeByte(8)
      ..write(obj.lastPlayed)
      ..writeByte(9)
      ..write(obj.playCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicTrackModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
