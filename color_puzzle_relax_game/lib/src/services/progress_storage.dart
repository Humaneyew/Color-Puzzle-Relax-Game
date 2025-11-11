import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/level_progress.dart';

class ProgressStorage {
  static const _storageKey = 'level_progress';

  Future<LevelProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      return const LevelProgress.initial();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return LevelProgress.fromJson(decoded);
      }
      if (decoded is Map) {
        return LevelProgress.fromJson(decoded.cast<String, dynamic>());
      }
    } catch (_) {
      // Ignore corrupted progress data and fall back to the defaults.
    }
    return const LevelProgress.initial();
  }

  Future<void> save(LevelProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(progress.toJson()),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
