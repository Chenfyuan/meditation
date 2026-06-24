import 'package:flutter/material.dart';

class Meditation {
  final String title;
  final String instructor;
  final String subtitle;
  final int durationMinutes;
  final String category;
  final List<Color> gradientColors;

  const Meditation({
    required this.title,
    required this.instructor,
    required this.subtitle,
    required this.durationMinutes,
    required this.category,
    required this.gradientColors,
  });
}

const List<Meditation> sampleMeditations = [
  Meditation(
    title: '晨间唤醒',
    instructor: 'Sarah',
    subtitle: '平静开启一天',
    durationMinutes: 8,
    category: '放松',
    gradientColors: [Color(0xFFE0BD97), Color(0xFFC49A72)],
  ),
  Meditation(
    title: '深度放松',
    instructor: 'Liam',
    subtitle: '释放身体紧张',
    durationMinutes: 15,
    category: '放松',
    gradientColors: [Color(0xFFD8AA98), Color(0xFFB67F6B)],
  ),
  Meditation(
    title: '专注当下',
    instructor: 'Mei',
    subtitle: '提升专注力',
    durationMinutes: 12,
    category: '专注',
    gradientColors: [Color(0xFFC1C4A2), Color(0xFF94A07A)],
  ),
  Meditation(
    title: '释放焦虑',
    instructor: 'Sarah',
    subtitle: '缓解日间压力',
    durationMinutes: 10,
    category: '减压',
    gradientColors: [Color(0xFFE0BD97), Color(0xFFB8865F)],
  ),
  Meditation(
    title: '身体扫描',
    instructor: 'Noah',
    subtitle: '睡前深度练习',
    durationMinutes: 20,
    category: '睡眠',
    gradientColors: [Color(0xFFB89A8A), Color(0xFF94A07A)],
  ),
];
