import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// NOTE: "sole_app" must match the `name:` in your pubspec.yaml
import 'package:sole_app/vault/models/note_item.dart';
import 'package:sole_app/vault/services/vault_storage.dart';

Future<VaultStorage> _open([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  return VaultStorage(await SharedPreferences.getInstance());
}

void main() {
  test('NoteItem toJson/fromJson round trip', () {
    const n = NoteItem(
        id: '1', title: 'Buy sneakers', dateText: '16 Nov 2026', isCompleted: true);
    final back = NoteItem.fromJson(n.toJson());
    expect(back.id, '1');
    expect(back.title, 'Buy sneakers');
    expect(back.dateText, '16 Nov 2026');
    expect(back.isCompleted, true);
  });

  test('NoteItem.fromJson is null-safe', () {
    final n = NoteItem.fromJson({});
    expect(n.title, '');
    expect(n.isCompleted, false);
  });

  test('defaults: light theme and Guest User', () async {
    final s = await _open();
    expect(s.isDarkMode, false);
    expect(s.userName, 'Guest User');
    expect(s.loadNotes(), isEmpty);
  });

  test('theme and username survive a "restart"', () async {
    final s = await _open();
    await s.setDarkMode(true);
    await s.setUserName('Aigerim');
    // new VaultStorage over the same prefs = cold start
    final again = VaultStorage(await SharedPreferences.getInstance());
    expect(again.isDarkMode, true);
    expect(again.userName, 'Aigerim');
  });

  test('notes list is saved as one JSON string and restored', () async {
    final s = await _open();
    final notes = [
      const NoteItem(id: '2', title: 'B', dateText: 'd2'),
      const NoteItem(id: '1', title: 'A', dateText: 'd1', isCompleted: true),
    ];
    await s.saveNotes(notes);
    final loaded = VaultStorage(await SharedPreferences.getInstance()).loadNotes();
    expect(loaded.map((n) => n.id), ['2', '1']);
    expect(loaded[1].isCompleted, true);
  });

  test('corrupted JSON does not crash', () async {
    final s = await _open({VaultStorage.notesKey: '{not json'});
    expect(s.loadNotes(), isEmpty);
  });
}
