import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note_item.dart';

/// Lab 11: the ONLY place that touches SharedPreferences.
/// The instance is created once in main() (before runApp) and injected,
/// so reads are synchronous and the first frame already has the real data.
class VaultStorage {
  static const String themeKey = 'app_theme_dark_mode';
  static const String nameKey = 'user_display_name';
  static const String notesKey = 'notes_json_list';
  static const String defaultName = 'Guest User';

  final SharedPreferences _prefs;
  const VaultStorage(this._prefs);

  // ---- bool: theme ----
  bool get isDarkMode => _prefs.getBool(themeKey) ?? false;
  Future<bool> setDarkMode(bool value) => _prefs.setBool(themeKey, value);

  // ---- String: username ----
  String get userName => _prefs.getString(nameKey) ?? defaultName;
  Future<bool> setUserName(String value) => _prefs.setString(nameKey, value);

  // ---- List<NoteItem> <-> one JSON string ----
  List<NoteItem> loadNotes() {
    final raw = _prefs.getString(notesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => NoteItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return []; // corrupted JSON -> start with an empty list, no crash
    }
  }

  Future<bool> saveNotes(List<NoteItem> notes) {
    final raw = jsonEncode(notes.map((n) => n.toJson()).toList());
    return _prefs.setString(notesKey, raw);
  }
}
