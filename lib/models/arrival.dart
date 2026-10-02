import 'transit_route.dart';

/// One upcoming departure of a route at a stop.
class Arrival {
  const Arrival({
    required this.id,
    required this.stopId,
    required this.route,
    required this.departsAt,
  });

  /// Stable across refreshes for the same scheduled departure, so reminders
  /// can be de-duplicated.
  final String id;
  final String stopId;
  final TransitRoute route;
  final DateTime departsAt;

  /// Whole minutes from [now] until departure. Zero or negative means due.
  int minutesAway(DateTime now) => departsAt.difference(now).inMinutes;
}
