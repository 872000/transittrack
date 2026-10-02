# 🚏 TransitTrack

**Never miss your ride.** An offline-first transit arrival tracker: save the stops you use every day, see live countdowns computed from bundled schedule data, and get "leave now" nudges before your bus pulls away — no account, no network, no API keys.

![build](https://img.shields.io/badge/build-passing-brightgreen)
![flutter](https://img.shields.io/badge/flutter-3.x-blue)
![platform](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20desktop-lightgrey)
![license](https://img.shields.io/badge/license-MIT-green)

![TransitTrack banner](docs/hero.png)

## Why TransitTrack?

Real-time transit apps need a data feed, an API key, and a connection. TransitTrack takes the opposite approach for the demo case: the schedule ships *inside* the app as headway data (every route's frequency windows), and every countdown is computed on-device from the current time. It works in a tunnel, on a plane, anywhere — and it's a clean showcase of testable domain logic, since the entire arrival engine is pure Dart with zero I/O.

## Features

- **Saved stops** — add stops from the bundled demo network, remove them, and reorder by drag to match your commute.
- **Upcoming arrivals** — next departures per stop computed from offline headway schedules, sorted and merged across routes, refreshing every 30 seconds.
- **"Leave now" reminders** — configurable lead time (5–30 min, settings dialog); the app nudges you when a departure enters the window. Each reminder fires once per departure.
- **Service-status notices** — bundled advisories (delays, planned work) surfaced as a banner on the home screen.
- **Local persistence** — saved stops and your lead-time preference live in a small JSON file on-device; nothing leaves the phone.
- **Clean Material 3 UI** — seeded color scheme, route color chips, countdown list per stop.

## Tech stack

| Layer | Choice |
|---|---|
| UI | Flutter + Material 3 |
| Arrival math | Pure-Dart `ArrivalEngine` (headway → departures, no I/O) |
| Reminders | Pure-Dart `ReminderService` (lead-time window, de-duplication) |
| Persistence | `StopStore` — JSON file via `dart:io` (directory injectable for tests) |
| Time | `Clock` abstraction (`SystemClock` / `FixedClock`) so tests use fixed instants |
| Tests | `flutter test` — 22 tests: arrival math, reminders, store round-trips, widget smoke tests |

## Quickstart

```bash
flutter pub get
flutter run
```

The app ships with a demo transit network (6 stops, 5 routes) and one stop pre-saveable from the **Add stop** button.

## Testing

```bash
flutter test        # 22 tests, all offline
flutter analyze     # clean
```

## Project structure

```
lib/
  main.dart                 # entry point, wires StopStore + app
  models/                   # Stop, TransitRoute/Headway, Arrival, ServiceNotice
  data/demo_schedule.dart   # bundled offline network: routes, stops, notices
  services/
    arrival_engine.dart     # headway schedules -> sorted upcoming departures
    reminder_service.dart   # "leave now" alerts inside the lead-time window
    stop_store.dart         # JSON persistence for stops + preferences
    clock.dart              # SystemClock / FixedClock for testability
  ui/                       # Material 3 screens: home, stop detail, add sheet
test/
  arrival_engine_test.dart  # headway math, sorting, boundaries, stable ids
  reminder_service_test.dart# lead-time windows, de-duplication, edge cases
  stop_store_test.dart      # file round-trips, reorder, removal
  widget_test.dart          # home renders saved stops + empty state
```

## Offline-first guarantee

TransitTrack makes zero network calls at runtime. The schedule, notices, and your saved stops are all on-device. There are no API keys, no secrets, and no analytics.
