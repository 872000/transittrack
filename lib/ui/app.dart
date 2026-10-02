import 'package:flutter/material.dart';
import '../services/clock.dart';
import '../services/stop_store.dart';
import 'home_screen.dart';

/// Root widget. [store] and [clock] are injectable so widget tests can
/// supply a temp-dir store and a fixed clock.
class TransitTrackApp extends StatelessWidget {
  const TransitTrackApp({
    super.key,
    required this.store,
    this.clock = const SystemClock(),
    this.refreshInterval = const Duration(seconds: 30),
  });

  final StopStore store;
  final Clock clock;

  /// How often countdowns and reminders re-evaluate. Pass [Duration.zero]
  /// in tests to disable the periodic timer.
  final Duration refreshInterval;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TransitTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E7C7B),
        ),
      ),
      home: HomeScreen(
        store: store,
        clock: clock,
        refreshInterval: refreshInterval,
      ),
    );
  }
}
