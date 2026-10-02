import 'package:flutter_test/flutter_test.dart';
import 'package:transittrack/models/arrival.dart';
import 'package:transittrack/models/transit_route.dart';
import 'package:transittrack/services/reminder_service.dart';

void main() {
  const route = TransitRoute(
    id: 'r1',
    shortName: '501',
    longName: '501 Queen',
    colorHex: 'C8102E',
    headways: <Headway>[],
  );

  Arrival arrivalAt(DateTime departsAt) => Arrival(
        id: 's|r1|${departsAt.millisecondsSinceEpoch}',
        stopId: 's',
        route: route,
        departsAt: departsAt,
      );

  const service = ReminderService();

  group('ReminderService', () {
    test('raises a reminder inside the lead time', () {
      final now = DateTime(2026, 10, 2, 12, 0);
      final due = service.due(
        arrivals: [arrivalAt(now.add(const Duration(minutes: 7)))],
        now: now,
        leadTime: const Duration(minutes: 10),
      );

      expect(due, hasLength(1));
      expect(due.first.title, 'Leave now');
      expect(due.first.body, contains('7 min'));
    });

    test('no reminder beyond the lead time', () {
      final now = DateTime(2026, 10, 2, 12, 0);
      final due = service.due(
        arrivals: [arrivalAt(now.add(const Duration(minutes: 11)))],
        now: now,
        leadTime: const Duration(minutes: 10),
      );

      expect(due, isEmpty);
    });

    test('a departure happening now still reminds', () {
      final now = DateTime(2026, 10, 2, 12, 0);
      final due = service.due(
        arrivals: [arrivalAt(now)],
        now: now,
        leadTime: const Duration(minutes: 10),
      );

      expect(due, hasLength(1));
      expect(due.first.body, contains('departing now'));
    });

    test('departures that already left are ignored', () {
      final now = DateTime(2026, 10, 2, 12, 0);
      final due = service.due(
        arrivals: [arrivalAt(now.subtract(const Duration(minutes: 2)))],
        now: now,
        leadTime: const Duration(minutes: 10),
      );

      expect(due, isEmpty);
    });

    test('acknowledged reminders are not raised twice', () {
      final now = DateTime(2026, 10, 2, 12, 0);
      final arrivals = [arrivalAt(now.add(const Duration(minutes: 5)))];
      final first = service.due(
        arrivals: arrivals,
        now: now,
        leadTime: const Duration(minutes: 10),
      );
      final second = service.due(
        arrivals: arrivals,
        now: now,
        leadTime: const Duration(minutes: 10),
        acknowledgedIds: first.map((r) => r.id).toSet(),
      );

      expect(first, hasLength(1));
      expect(second, isEmpty);
    });

    test('custom lead times are respected', () {
      final now = DateTime(2026, 10, 2, 12, 0);
      final arrivals = [arrivalAt(now.add(const Duration(minutes: 20)))];

      expect(
        service.due(
          arrivals: arrivals,
          now: now,
          leadTime: const Duration(minutes: 15),
        ),
        isEmpty,
      );
      expect(
        service.due(
          arrivals: arrivals,
          now: now,
          leadTime: const Duration(minutes: 25),
        ),
        hasLength(1),
      );
    });
  });
}
