class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int reward;
  final bool isCompleted;
  final double progress;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.reward,
    required this.isCompleted,
    required this.progress,
  });
}

enum ChallengeType { daily, weekly, achievement, garden, meditation, social }
