class CameraPhoto {
  final String id;
  final String path;
  final String originalText;
  final Map<String, String> translations;
  final DateTime timestamp;

  const CameraPhoto({
    required this.id,
    required this.path,
    required this.originalText,
    required this.translations,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'path': path,
    'originalText': originalText,
    'translations': translations,
    'ts': timestamp.millisecondsSinceEpoch,
  };

  factory CameraPhoto.fromMap(Map<String, dynamic> m) => CameraPhoto(
    id: m['id'] as String,
    path: m['path'] as String,
    originalText: (m['originalText'] ?? '') as String,
    translations: Map<String, String>.from(
      (m['translations'] as Map?) ?? const {},
    ),
    timestamp: DateTime.fromMillisecondsSinceEpoch((m['ts'] as int?) ?? 0),
  );
}
