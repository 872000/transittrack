import '../models/service_notice.dart';
import '../models/stop.dart';
import '../models/transit_route.dart';

/// Bundled offline demo network. No network calls: every departure shown by
/// the app is computed from these headway schedules.
const List<TransitRoute> demoRoutes = <TransitRoute>[
  TransitRoute(
    id: '501',
    shortName: '501',
    longName: '501 Queen',
    colorHex: 'C8102E',
    headways: <Headway>[
      Headway(start: '06:00', end: '09:00', everyMinutes: 8),
      Headway(start: '09:00', end: '15:00', everyMinutes: 10),
      Headway(start: '15:00', end: '19:00', everyMinutes: 8),
      Headway(start: '19:00', end: '23:30', everyMinutes: 15),
    ],
  ),
  TransitRoute(
    id: '506',
    shortName: '506',
    longName: '506 Carlton',
    colorHex: '0E7C3E',
    headways: <Headway>[
      Headway(start: '06:00', end: '10:00', everyMinutes: 10),
      Headway(start: '10:00', end: '19:00', everyMinutes: 8),
      Headway(start: '19:00', end: '23:00', everyMinutes: 15),
    ],
  ),
  TransitRoute(
    id: '939',
    shortName: '939',
    longName: '939 Finch Express',
    colorHex: '7B1FA2',
    headways: <Headway>[
      Headway(start: '05:30', end: '09:30', everyMinutes: 10),
      Headway(start: '09:30', end: '15:00', everyMinutes: 12),
      Headway(start: '15:00', end: '19:00', everyMinutes: 10),
      Headway(start: '19:00', end: '23:00', everyMinutes: 20),
    ],
  ),
  TransitRoute(
    id: '29',
    shortName: '29',
    longName: '29 Dufferin',
    colorHex: 'D97706',
    headways: <Headway>[
      Headway(start: '06:00', end: '12:00', everyMinutes: 12),
      Headway(start: '12:00', end: '19:00', everyMinutes: 10),
      Headway(start: '19:00', end: '23:00', everyMinutes: 15),
    ],
  ),
  TransitRoute(
    id: 'line1',
    shortName: 'Line 1',
    longName: 'Line 1 Yonge-University',
    colorHex: 'F5C518',
    headways: <Headway>[
      Headway(start: '06:00', end: '09:30', everyMinutes: 3),
      Headway(start: '09:30', end: '15:00', everyMinutes: 5),
      Headway(start: '15:00', end: '19:00', everyMinutes: 3),
      Headway(start: '19:00', end: '23:30', everyMinutes: 6),
    ],
  ),
];

/// Lookup helper for the UI and engine.
Map<String, TransitRoute> get demoRoutesById =>
    <String, TransitRoute>{for (final r in demoRoutes) r.id: r};

const List<Stop> demoStops = <Stop>[
  Stop(
    id: 'queen_spadina',
    name: 'Queen St W / Spadina Ave',
    description: 'Streetcar stop · downtown',
    routeIds: <String>['501', '506'],
  ),
  Stop(
    id: 'finch_station',
    name: 'Finch Station',
    description: 'Subway + bus terminal',
    routeIds: <String>['939', 'line1'],
  ),
  Stop(
    id: 'union_station',
    name: 'Union Station',
    description: 'Downtown transit hub',
    routeIds: <String>['501', 'line1'],
  ),
  Stop(
    id: 'bloor_ossington',
    name: 'Bloor St W / Ossington Ave',
    description: 'West-end stop',
    routeIds: <String>['506', '29'],
  ),
  Stop(
    id: 'king_bay',
    name: 'King St W / Bay St',
    description: 'Financial district',
    routeIds: <String>['501', 'line1'],
  ),
  Stop(
    id: 'dufferin_station',
    name: 'Dufferin Station',
    description: 'Bloor line',
    routeIds: <String>['29', '506'],
  ),
];

/// Service-status notices, worst severity first. Bundled with the app —
/// a real deployment would refresh these from an agency feed.
const List<ServiceNotice> demoNotices = <ServiceNotice>[
  ServiceNotice(
    id: 'n1',
    title: '501 Queen: expect delays near Humber Loop',
    body: 'Track work is causing 5–10 minute delays eastbound until further notice.',
    severity: NoticeSeverity.warning,
    routeIds: <String>['501'],
  ),
  ServiceNotice(
    id: 'n2',
    title: 'Line 1: planned weekend track work',
    body: 'Shuttle buses replace trains between St Clair and Eglinton on Saturday and Sunday.',
    severity: NoticeSeverity.info,
    routeIds: <String>['line1'],
  ),
];
