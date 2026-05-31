import 'dart:ui';

import 'package:hive/hive.dart';

part 'music_track_model.g.dart';

@HiveType(typeId: 6)
class MusicTrackModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String artist;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String audioUrl;

  @HiveField(5)
  final String imageUrl;

  @HiveField(6)
  final int duration; // in seconds

  @HiveField(7)
  final bool isFavorite;

  @HiveField(8)
  final DateTime? lastPlayed;

  @HiveField(9)
  final int playCount;

  MusicTrackModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.category,
    required this.audioUrl,
    required this.imageUrl,
    required this.duration,
    this.isFavorite = false,
    this.lastPlayed,
    this.playCount = 0,
  });

  MusicTrackModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? category,
    String? audioUrl,
    String? imageUrl,
    int? duration,
    bool? isFavorite,
    DateTime? lastPlayed,
    int? playCount,
  }) {
    return MusicTrackModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      category: category ?? this.category,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      duration: duration ?? this.duration,
      isFavorite: isFavorite ?? this.isFavorite,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      playCount: playCount ?? this.playCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'category': category,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'duration': duration,
      'isFavorite': isFavorite,
      'lastPlayed': lastPlayed?.toIso8601String(),
      'playCount': playCount,
    };
  }

  factory MusicTrackModel.fromJson(Map<String, dynamic> json) {
    return MusicTrackModel(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      category: json['category'],
      audioUrl: json['audioUrl'],
      imageUrl: json['imageUrl'],
      duration: json['duration'],
      isFavorite: json['isFavorite'],
      lastPlayed: json['lastPlayed'] != null
          ? DateTime.parse(json['lastPlayed'])
          : null,
      playCount: json['playCount'],
    );
  }
}

class MusicTrack {
  final String id;
  final String title;
  final String artist;
  final Duration duration;
  final String category;
  final Color color;
  final String asset;

  MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.category,
    required this.color,
    required this.asset,
  });
}
