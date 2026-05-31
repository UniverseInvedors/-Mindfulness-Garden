import 'package:hive/hive.dart';

part 'mood_model.g.dart';

@HiveType(typeId: 4)
class MoodModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String mood;

  @HiveField(3)
  final double rating;

  @HiveField(4)
  final String? note;

  @HiveField(5)
  final List<String> tags;

  MoodModel({
    required this.id,
    required this.date,
    required this.mood,
    required this.rating,
    this.note,
    this.tags = const [],
  });

  MoodModel copyWith({
    String? id,
    DateTime? date,
    String? mood,
    double? rating,
    String? note,
    List<String>? tags,
  }) {
    return MoodModel(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      rating: rating ?? this.rating,
      note: note ?? this.note,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mood': mood,
      'rating': rating,
      'note': note,
      'tags': tags,
    };
  }

  factory MoodModel.fromJson(Map<String, dynamic> json) {
    return MoodModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      mood: json['mood'],
      rating: json['rating'].toDouble(),
      note: json['note'],
      tags: List<String>.from(json['tags']),
    );
  }
}
