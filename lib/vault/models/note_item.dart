/// Lab 11: domain model of one note.
/// Serialized to a Map by [toJson] and restored by [NoteItem.fromJson].
class NoteItem {
  final String id;
  final String title;
  final String dateText;
  final bool isCompleted;

  const NoteItem({
    required this.id,
    required this.title,
    required this.dateText,
    this.isCompleted = false,
  });

  /// Objects are immutable -> toggling creates a copy.
  NoteItem copyWith({bool? isCompleted}) => NoteItem(
        id: id,
        title: title,
        dateText: dateText,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dateText': dateText,
        'isCompleted': isCompleted,
      };

  /// Null-safe: a damaged/old record never crashes the app.
  factory NoteItem.fromJson(Map<String, dynamic> json) => NoteItem(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        dateText: json['dateText'] as String? ?? '',
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}
