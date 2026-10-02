import '../models/arrival.dart';
import '../models/stop.dart';
import '../models/transit_route.dart';

/// Computes upcoming departures for a stop from the bundled offline
/// headway schedule. Pure logic: no I/O, no network, fully testable.
class ArrivalEngine {
  const ArrivalEngine();

  /// Returns up to [limit] arrivals at [stop], sorted by departure time.
  /// Departures that left more than a minute ago are excluded; a departure
  /// happening right now is kept so the UI can show "Due".
  List<Arrival> upcoming({
    required Stop stop,
    required Map<String, TransitRoute> routesById,
    required DateTime now,
    int limit = 8,
  }) {
    final candidates = <Arrival>[];
    for (final routeId in stop.routeIds) {
      final route = routesById[routeId];
      if (route == null) continue;
      for (final headway in route.headways) {
        candidates.addAll(
          _departures(
            route: route,
            stop: stop,
            headway: headway,
            now: now,
            limit: limit,
          ),
        );
      }
    }
    candidates.sort((a, b) => a.departsAt.compareTo(b.departsAt));

    final cutoff = now.subtract(const Duration(minutes: 1));
    final seen = <String>{};
    final result = <Arrival>[];
    for (final arrival in candidates) {
      if (!arrival.departsAt.isAfter(cutoff)) continue;
      if (!seen.add(arrival.id)) continue; // overlapping headway windows
      result.add(arrival);
      if (result.length >= limit) break;
    }
    return result;
  }

  List<Arrival> _departures({
    required TransitRoute route,
    required Stop stop,
    required Headway headway,
    required DateTime now,
    required int limit,
  }) {
    final start = headway.startMinutes;
    final end = headway.endMinutes;
    final every = headway.everyMinutes;
    final nowMinutes = now.hour * 60 + now.minute + now.second / 60.0;

    final int first;
    if (nowMinutes <= start) {
      first = start;
    } else if (nowMinutes > end) {
      return const [];
    } else {
      final skipped = ((nowMinutes - start) / every).ceil();
      first = start + skipped * every;
    }

    final day = DateTime(now.year, now.month, now.day);
    final departures = <Arrival>[];
    for (var m = first; m <= end && departures.length < limit; m += every) {
      final departsAt = day.add(Duration(minutes: m));
      departures.add(
        Arrival(
          id: '${stop.id}|${route.id}|${departsAt.millisecondsSinceEpoch}',
          stopId: stop.id,
          route: route,
          departsAt: departsAt,
        ),
      );
    }
    return departures;
  }
}
