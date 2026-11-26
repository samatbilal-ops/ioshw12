import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// NOTE: "sole_app" must match the `name:` in your pubspec.yaml
import 'package:sole_app/lw13/models/diary_entry.dart';
import 'package:sole_app/lw13/services/diary_storage.dart';
import 'package:sole_app/lw13/utils/formatters.dart';

DiaryEntry _entry(String id, {String caption = 'Campus Quad'}) => DiaryEntry(
      id: id,
      photoPath: '/data/photo_$id.jpg',
      timestamp: DateTime(2026, 11, 24, 14, 30, 15),
      latitude: 43.238949,
      longitude: 76.889709,
      accuracy: 12.4,
      altitude: 800.5,
      caption: caption,
    );

void main() {
  group('formatters', () {
    test('timestamp', () {
      expect(formatTimestamp(DateTime(2026, 11, 24, 14, 30, 15)),
          '2026-11-24 14:30:15');
      expect(formatTimestamp(DateTime(2026, 1, 2, 3, 4, 5)),
          '2026-01-02 03:04:05');
    });

    test('degrees and accuracy', () {
      expect(formatDegrees(43.238949), '43.238949');
      expect(formatAccuracy(12.44), '± 12.4 m');
    });

    test('coordinates with hemispheres', () {
      expect(formatCoordinates(43.238949, 76.889709), '43.2389° N, 76.8897° E');
      expect(formatCoordinates(-33.8688, -70.5), '33.8688° S, 70.5000° W');
    });
  });

  group('DiaryEntry', () {
    test('toJson/fromJson round trip', () {
      final back = DiaryEntry.fromJson(_entry('1').toJson());
      expect(back.id, '1');
      expect(back.photoPath, '/data/photo_1.jpg');
      expect(back.timestamp, DateTime(2026, 11, 24, 14, 30, 15));
      expect(back.latitude, 43.238949);
      expect(back.longitude, 76.889709);
      expect(back.accuracy, 12.4);
      expect(back.altitude, 800.5);
      expect(back.caption, 'Campus Quad');
    });

    test('fromJson is null-safe', () {
      final e = DiaryEntry.fromJson({});
      expect(e.caption, '');
      expect(e.latitude, 0);
      expect(e.photoPath, '');
    });

    test('fromJson accepts ints for numbers', () {
      final e = DiaryEntry.fromJson({'latitude': 43, 'longitude': 76});
      expect(e.latitude, 43.0);
      expect(e.longitude, 76.0);
    });
  });

  group('DiaryStorage', () {
    Future<DiaryStorage> open([Map<String, Object> initial = const {}]) async {
      SharedPreferences.setMockInitialValues(initial);
      return DiaryStorage(await SharedPreferences.getInstance());
    }

    test('empty at the start', () async {
      expect((await open()).load(), isEmpty);
    });

    test('entries survive a restart, order is kept', () async {
      final s = await open();
      await s.save([_entry('2', caption: 'B'), _entry('1', caption: 'A')]);
      final again = DiaryStorage(await SharedPreferences.getInstance());
      final loaded = again.load();
      expect(loaded.map((e) => e.id), ['2', '1']);
      expect(loaded.first.caption, 'B');
    });

    test('corrupted JSON does not crash', () async {
      final s = await open({DiaryStorage.entriesKey: '{oops'});
      expect(s.load(), isEmpty);
    });
  });
}
