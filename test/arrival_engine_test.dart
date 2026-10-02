import 'package:flutter_test/flutter_test.dart';
import 'package:transittrack/models/stop.dart';
import 'package:transittrack/models/transit_route.dart';
import 'package:transittrack/services/arrival_engine.dart';

void main() {
  const route = TransitRoute(
    id: 'r10',
    shortName: '10',
    longName: '10 Test Line',
    colorHex: '123456',
    headways: <Headway>[
      Headway(start: '06:00', end: '09:00', everyMinutes: 15),
      Headway(start: '09:00', end: '12:00', everyMinutes: 30),
    ],
  );
  const stop = Stop(id: 's1', name: 'Test Stop', routeIds: <String>['r10']);
  const engine = ArrivalEngine();
  Map<String, TransitRoute> routes() => <String, TransitRoute>{'r10': route};

  group('ArrivalEngine', () {
    test('computes the next departures inside a headway window', () {
      final now = DateTime(2026, 10, 2, 7, 7);
      final arrivals =
          engine.upcoming(stop: stop, routesById: routes(), now: now, limit: 3);

      expect(arrivals.map((a) => a.departsAt), [
        DateTime(2026, 10, 2, 7, 15),
        DateTime(2026, 10, 2, 7, 30),
        DateTime(2026, 10, 2, 7, 45),
      ]);
    });

    test('a departure happening right now is kept (shows as Due)', () {
      final now = DateTime(2026, 10, 2, 7, 30);
      final arrivals =
          engine.upcoming(stop: stop, routesById: routes(), now: now, limit: 1);

      expect(arrivals, hasLength(1));
      expect(arrivals.first.departsAt, DateTime(2026, 10, 2, 7, 30));
      expect(arrivals.first.minutesAway(now), 0);
    });

    test('departures that already left are excluded', () {
      final now = DateTime(2026, 10, 2, 7, 31, 30);
      final arrivals =
          engine.upcoming(stop: stop, routesById: routes(), now: now, limit: 2);

      expect(arrivals.first.departsAt, DateTime(2026, 10, 2, 7, 45));
    });

    test('before the first window, the day starts at the window start', () {
      final now = DateTime(2026, 10, 2, 5, 10);
      final arrivals =
          engine.upcoming(stop: stop, routesById: routes(), now: now, limit: 1);

      expect(arrivals.first.departsAt, DateTime(2026, 10, 2, 6, 0));
    });

    test('after the last window, no arrivals are returned', () {
      final now = DateTime(2026, 10, 2, 23, 45);
      final arrivals = engine.upcoming(stop: stop, routesById: routes(), now: now);

      expect(arrivals, isEmpty);
    });

    test('results are sorted and merged across routes', () {
      const routeB = TransitRoute(
        id: 'r20',
        shortName: '20',
        longName: '20 Other Line',
        colorHex: '654321',
        headways: <Headway>[
          Headway(start: '06:00', end: '12:00', everyMinutes: 20),
        ],
      );
      const twoRoutes = Stop(
        id: 's2',
        name: 'Two-route stop',
        routeIds: <String>['r10', 'r20'],
      );
      final now = DateTime(2026, 10, 2, 7, 0);
      final arrivals = engine.upcoming(
        stop: twoRoutes,
        routesById: <String, TransitRoute>{'r10': route, 'r20': routeB},
        now: now,
        limit: 4,
      );

      expect(arrivals.map((a) => a.departsAt), [
        DateTime(2026, 10, 2, 7, 0), // r10
        DateTime(2026, 10, 2, 7, 0), // r20
        DateTime(2026, 10, 2, 7, 15), // r10
        DateTime(2026, 10, 2, 7, 20), // r20
      ]);
      final ids = arrivals.map((a) => a.id).toSet();
      expect(ids, hasLength(4)); // overlapping times stay distinct per route
    });

    test('unknown route ids on a stop are skipped', () {
      const badStop = Stop(id: 's3', name: 'Bad', routeIds: <String>['nope']);
      final arrivals = engine.upcoming(
        stop: badStop,
        routesById: routes(),
        now: DateTime(2026, 10, 2, 7, 0),
      );
      expect(arrivals, isEmpty);
    });

    test('arrival ids are stable across refreshes', () {
      final now = DateTime(2026, 10, 2, 7, 7);
      final first =
          engine.upcoming(stop: stop, routesById: routes(), now: now, limit: 3);
      final second = engine.upcoming(
        stop: stop,
        routesById: routes(),
        now: now.add(const Duration(seconds: 20)),
        limit: 3,
      );
      expect(
        second.map((a) => a.id),
        first.map((a) => a.id),
      );
    });
  });
}
