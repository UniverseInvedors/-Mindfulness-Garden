import 'package:hive/hive.dart';

part 'session_model.g.dart';

@HiveType(typeId: 3)
class SessionModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime startTime;

  @HiveField(2)
  final int durationMinutes;

  @HiveField(3)
  final String meditationType;

  @HiveField(4)
  final String focusArea;

  @HiveField(5)
  final int initialHeartRate;

  @HiveField(6)
  final int finalHeartRate;

  @HiveField(7)
  final String moodBefore;

  @HiveField(8)
  final String moodAfter;

  @HiveField(9)
  final String? notes;

  @HiveField(10)
  final List<String> soundsUsed;

  SessionModel({
    required this.id,
    required this.startTime,
    required this.durationMinutes,
    required this.meditationType,
    required this.focusArea,
    this.initialHeartRate = 0,
    this.finalHeartRate = 0,
    this.moodBefore = '',
    this.moodAfter = '',
    this.notes,
    this.soundsUsed = const [],
  });

  SessionModel copyWith({
    String? id,
    DateTime? startTime,
    int? durationMinutes,
    String? meditationType,
    String? focusArea,
    int? initialHeartRate,
    int? finalHeartRate,
    String? moodBefore,
    String? moodAfter,
    String? notes,
    List<String>? soundsUsed,
  }) {
    return SessionModel(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      meditationType: meditationType ?? this.meditationType,
      focusArea: focusArea ?? this.focusArea,
      initialHeartRate: initialHeartRate ?? this.initialHeartRate,
      finalHeartRate: finalHeartRate ?? this.finalHeartRate,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter: moodAfter ?? this.moodAfter,
      notes: notes ?? this.notes,
      soundsUsed: soundsUsed ?? this.soundsUsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'meditationType': meditationType,
      'focusArea': focusArea,
      'initialHeartRate': initialHeartRate,
      'finalHeartRate': finalHeartRate,
      'moodBefore': moodBefore,
      'moodAfter': moodAfter,
      'notes': notes,
      'soundsUsed': soundsUsed,
    };
  }

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      durationMinutes: json['durationMinutes'],
      meditationType: json['meditationType'],
      focusArea: json['focusArea'],
      initialHeartRate: json['initialHeartRate'],
      finalHeartRate: json['finalHeartRate'],
      moodBefore: json['moodBefore'],
      moodAfter: json['moodAfter'],
      notes: json['notes'],
      soundsUsed: List<String>.from(json['soundsUsed']),
    );
  }
}
