import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/player_progress.dart';
import '../../data/level.dart';

class ProgressRepository {
  ProgressRepository(this._preferences);

  static const _storageKey = 'player-progress';

  final SharedPreferences _preferences;

  static Future<ProgressRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ProgressRepository(prefs);
  }

  Future<PlayerProgress> loadProgress(List<GradientPuzzleLevel> levels) async {
    final raw = _preferences.getString(_storageKey);
    if (raw == null) {
      return PlayerProgress.initial(levels);
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, Object?>) {
        return PlayerProgress.fromJson(decoded, levels);
      }
    } catch (_) {
      // ignore malformed storage and fallback to defaults
    }
    return PlayerProgress.initial(levels);
  }

  Future<void> saveProgress(PlayerProgress progress) async {
    final encoded = jsonEncode(progress.toJson());
    await _preferences.setString(_storageKey, encoded);
  }
}
