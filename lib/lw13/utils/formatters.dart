/// Pure formatting helpers (easy to unit-test, no Flutter needed).

String _two(int n) => n.toString().padLeft(2, '0');

/// 2026-11-24 14:30:15
String formatTimestamp(DateTime t) =>
    '${t.year}-${_two(t.month)}-${_two(t.day)} '
    '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';

/// 43.238949 (6 decimals, like the lab mock-up)
String formatDegrees(double value) => value.toStringAsFixed(6);

/// 43.2389° N, 76.8897° E
String formatCoordinates(double lat, double lon) {
  final ns = lat >= 0 ? 'N' : 'S';
  final ew = lon >= 0 ? 'E' : 'W';
  return '${lat.abs().toStringAsFixed(4)}° $ns, '
      '${lon.abs().toStringAsFixed(4)}° $ew';
}

/// ± 12.4 m
String formatAccuracy(double meters) => '± ${meters.toStringAsFixed(1)} m';
