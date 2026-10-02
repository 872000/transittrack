import '../models/arrival.dart';

/// A "leave now" nudge for one specific departure.
class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.body,
    required this.triggerFor,
  });

  /// Matches the [Arrival.id] it was raised for (used for de-duplication).
  final String id;
  final String title;
  final String body;
  final DateTime triggerFor;
}

/// Decides which arrivals deserve a leave-now alert. Pure logic: the app
/// layer chooses how to surface them (SnackBar in the demo UI).
class ReminderService {
  const ReminderService();

  /// Returns a reminder for every arrival departing within [leadTime] from
  /// [now], skipping departures that already left and ids already present in
  /// [acknowledgedIds].
  List<Reminder> due({
    required List<Arrival> arrivals,
    required DateTime now,
    required Duration leadTime,
    Set<String> acknowledgedIds = const <String>{},
  }) {
    final reminders = <Reminder>[];
    for (final arrival in arrivals) {
      final away = arrival.departsAt.difference(now);
      if (away.isNegative || away > leadTime) continue;
      if (acknowledgedIds.contains(arrival.id)) continue;
      final minutes = away.inMinutes;
      reminders.add(
        Reminder(
          id: arrival.id,
          title: 'Leave now',
          body: minutes <= 0
              ? '${arrival.route.shortName} is departing now — go!'
              : '${arrival.route.shortName} departs in $minutes min — '
                  'time to head out',
          triggerFor: arrival.departsAt,
        ),
      );
    }
    return reminders;
  }
}
