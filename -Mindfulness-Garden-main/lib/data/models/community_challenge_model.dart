import 'package:flutter/material.dart';

class CommunityChallenge {
  final String id;
  final String title;
  final String description;
  final Color color;
  final int participantCount;
  final int targetMinutes;

  CommunityChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    required this.participantCount,
    required this.targetMinutes,
  });
}
