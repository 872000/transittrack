/// One service window of a route, e.g. "every 10 minutes, 09:00–15:00".
class Headway {
  const Headway({
    required this.start,
    required this.end,
    required this.everyMinutes,
  });

  /// "HH:MM" in 24-hour local time.
  final String start;

  /// "HH:MM" in 24-hour local time.
  final String end;

  final int everyMinutes;

  int get startMinutes => _toMinutes(start);
  int get endMinutes => _toMinutes(end);

  static int _toMinutes(String hhmm) {
    final parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

/// A transit route with an offline headway-based schedule.
class TransitRoute {
  const TransitRoute({
    required this.id,
    required this.shortName,
    required this.longName,
    required this.colorHex,
    required this.headways,
  });

  final String id;
  final String shortName;
  final String longName;

  /// 6-digit RGB hex, e.g. "C8102E".
  final String colorHex;

  final List<Headway> headways;
}
