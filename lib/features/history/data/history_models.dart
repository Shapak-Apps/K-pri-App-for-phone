class HistoryEntry {
  final String id;
  final String source;
  final String result;
  final String from;
  final String to;
  final DateTime timestamp;
  final bool isFavorite;

  const HistoryEntry({
    required this.id,
    required this.source,
    required this.result,
    required this.from,
    required this.to,
    required this.timestamp,
    this.isFavorite = false,
  });

  HistoryEntry copyWith({bool? isFavorite}) => HistoryEntry(
    id: id,
    source: source,
    result: result,
    from: from,
    to: to,
    timestamp: timestamp,
    isFavorite: isFavorite ?? this.isFavorite,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'source': source,
    'result': result,
    'from': from,
    'to': to,
    'ts': timestamp.millisecondsSinceEpoch,
    'fav': isFavorite,
  };

  factory HistoryEntry.fromMap(Map<String, dynamic> m) => HistoryEntry(
    id: m['id'] as String,
    source: m['source'] as String,
    result: m['result'] as String,
    from: m['from'] as String,
    to: m['to'] as String,
    timestamp: DateTime.fromMillisecondsSinceEpoch(m['ts'] as int),
    isFavorite: (m['fav'] as bool?) ?? false,
  );
}
