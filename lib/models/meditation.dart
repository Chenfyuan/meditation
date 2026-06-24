import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class Meditation {
  final String id;
  final String title;
  final String instructor;
  final String subtitle;
  final int durationMinutes;
  final String category;
  final String themeKey;

  const Meditation({
    required this.id,
    required this.title,
    required this.instructor,
    required this.subtitle,
    required this.durationMinutes,
    required this.category,
    this.themeKey = 'sand',
  });

  List<Color> get gradientColors => AppColors.meditationGradientFor(themeKey);

  factory Meditation.fromJson(Map<String, dynamic> json) {
    return Meditation(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      instructor: json['instructor'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      durationMinutes: _readInt(json['durationMinutes']),
      category: json['category'] as String? ?? '',
      themeKey: json['themeKey'] as String? ?? 'sand',
    );
  }
}

int _readInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}
