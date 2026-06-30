// lib/features/meditation/models/meditation_session.dart
class MeditationSession {
  final int id;
  final String title;
  final String teacher;
  final Duration duration;
  final String category;
  final String difficulty;
  final String thumbnail;
  final String videoUrl;
  final String? audioUrl;

  MeditationSession({
    required this.id,
    required this.title,
    required this.teacher,
    required this.duration,
    required this.category,
    required this.difficulty,
    required this.thumbnail,
    required this.videoUrl,
    this.audioUrl,
  });
}
