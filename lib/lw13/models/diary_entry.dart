/// One record of the Geotagged Photo Diary: photo path + time + GPS + caption.
class DiaryEntry {
  final String id;
  final String photoPath;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double accuracy; // meters
  final double altitude; // meters
  final String caption;

  const DiaryEntry({
    required this.id,
    required this.photoPath,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.altitude,
    required this.caption,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'photoPath': photoPath,
        'timestamp': timestamp.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'altitude': altitude,
        'caption': caption,
      };

  /// Null-safe: a damaged record never crashes the diary.
  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
        id: json['id'] as String? ?? '',
        photoPath: json['photoPath'] as String? ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
        accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
        altitude: (json['altitude'] as num?)?.toDouble() ?? 0,
        caption: json['caption'] as String? ?? '',
      );
}
