import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PlayerSave {
  const PlayerSave({
    this.completedLevels = const {},
    this.currentLevel = 1,
    this.music = true,
    this.effects = true,
    this.haptics = true,
    this.reducedMotion = false,
    this.languageCode,
  });
  final Set<int> completedLevels;
  final int currentLevel;
  final bool music;
  final bool effects;
  final bool haptics;
  final bool reducedMotion;
  final String? languageCode;

  PlayerSave copyWith({
    Set<int>? completedLevels,
    int? currentLevel,
    bool? music,
    bool? effects,
    bool? haptics,
    bool? reducedMotion,
    String? languageCode,
  }) => PlayerSave(
    completedLevels: completedLevels ?? this.completedLevels,
    currentLevel: currentLevel ?? this.currentLevel,
    music: music ?? this.music,
    effects: effects ?? this.effects,
    haptics: haptics ?? this.haptics,
    reducedMotion: reducedMotion ?? this.reducedMotion,
    languageCode: languageCode ?? this.languageCode,
  );

  Map<String, dynamic> toJson() => {
    'completedLevels': completedLevels.toList()..sort(),
    'currentLevel': currentLevel,
    'music': music,
    'effects': effects,
    'haptics': haptics,
    'reducedMotion': reducedMotion,
    'languageCode': languageCode,
  };

  factory PlayerSave.fromJson(Map<String, dynamic> json) => PlayerSave(
    completedLevels: ((json['completedLevels'] as List?) ?? const [])
        .whereType<num>()
        .map((n) => n.toInt())
        .toSet(),
    currentLevel: (json['currentLevel'] as num?)?.toInt() ?? 1,
    music: json['music'] as bool? ?? true,
    effects: json['effects'] as bool? ?? true,
    haptics: json['haptics'] as bool? ?? true,
    reducedMotion: json['reducedMotion'] as bool? ?? false,
    languageCode: json['languageCode'] as String?,
  );
}

class SaveStore {
  static const _key = 'pfs_game_01_save_v1';

  static Future<PlayerSave> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const PlayerSave();
    try {
      return PlayerSave.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const PlayerSave();
    }
  }

  static Future<void> save(PlayerSave save) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(save.toJson()));
  }
}
