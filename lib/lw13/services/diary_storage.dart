import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/diary_entry.dart';

/// Offline persistence of the diary: the whole list as ONE JSON string
/// (same technique as LW11). Photos themselves stay as files on disk;
/// only their paths are stored here.
class DiaryStorage {
  static const String entriesKey = 'lw13_diary_entries';

  final SharedPreferences _prefs;
  const DiaryStorage(this._prefs);

  List<DiaryEntry> load() {
    final raw = _prefs.getString(entriesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => DiaryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return []; // corrupted JSON -> empty diary, no crash
    }
  }

  Future<bool> save(List<DiaryEntry> entries) => _prefs.setString(
        entriesKey,
        jsonEncode(entries.map((e) => e.toJson()).toList()),
      );
}
