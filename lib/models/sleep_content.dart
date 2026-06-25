class SleepContent {
  final SleepStory featuredStory;
  final List<AmbientSound> ambientSounds;
  final List<SleepItem> sleepItems;

  const SleepContent({
    required this.featuredStory,
    required this.ambientSounds,
    required this.sleepItems,
  });

  factory SleepContent.fromJson(Map<String, dynamic> json) {
    return SleepContent(
      featuredStory: SleepStory.fromJson(
        Map<String, dynamic>.from(json['featuredStory'] as Map? ?? const {}),
      ),
      ambientSounds: (json['ambientSounds'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => AmbientSound.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
      sleepItems: (json['sleepItems'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => SleepItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
    );
  }
}

class SleepStory {
  final String id;
  final String title;
  final String descriptor;
  final int durationMinutes;
  final String themeKey;
  final String? audioUrl;

  const SleepStory({
    required this.id,
    required this.title,
    required this.descriptor,
    required this.durationMinutes,
    required this.themeKey,
    this.audioUrl,
  });

  String get metadata => '$descriptor · $durationMinutes 分钟';

  factory SleepStory.fromJson(Map<String, dynamic> json) {
    return SleepStory(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      descriptor: json['descriptor'] as String? ?? '',
      durationMinutes: _readInt(json['durationMinutes']),
      themeKey: json['themeKey'] as String? ?? 'cocoa',
      audioUrl: json['audioUrl'] as String?,
    );
  }
}

class AmbientSound {
  final String id;
  final String title;
  final String themeKey;
  final bool isFeatured;
  final String? audioUrl;

  const AmbientSound({
    required this.id,
    required this.title,
    required this.themeKey,
    this.isFeatured = false,
    this.audioUrl,
  });

  factory AmbientSound.fromJson(Map<String, dynamic> json) {
    return AmbientSound(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      themeKey: json['themeKey'] as String? ?? 'stone',
      isFeatured: json['isFeatured'] as bool? ?? false,
      audioUrl: json['audioUrl'] as String?,
    );
  }
}

class SleepItem {
  final String id;
  final String title;
  final String type;
  final int durationMinutes;
  final String themeKey;
  final String? audioUrl;

  const SleepItem({
    required this.id,
    required this.title,
    required this.type,
    required this.durationMinutes,
    required this.themeKey,
    this.audioUrl,
  });

  String get metadata => '$type · $durationMinutes 分钟';

  factory SleepItem.fromJson(Map<String, dynamic> json) {
    return SleepItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? '',
      durationMinutes: _readInt(json['durationMinutes']),
      themeKey: json['themeKey'] as String? ?? 'stone',
      audioUrl: json['audioUrl'] as String?,
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
