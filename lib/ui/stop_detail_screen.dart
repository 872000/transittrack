import 'dart:async';

import 'package:flutter/material.dart';

import '../data/demo_schedule.dart';
import '../models/stop.dart';
import '../services/arrival_engine.dart';
import '../services/clock.dart';
import 'widgets/route_dot.dart';

/// Detail view for one stop: the upcoming departures with live countdowns.
class StopDetailScreen extends StatefulWidget {
  const StopDetailScreen({
    super.key,
    required this.stop,
    required this.clock,
  });

  final Stop stop;
  final Clock clock;

  @override
  State<StopDetailScreen> createState() => _StopDetailScreenState();
}

class _StopDetailScreenState extends State<StopDetailScreen> {
  final _engine = const ArrivalEngine();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final now = widget.clock.now();
    final arrivals = _engine.upcoming(
      stop: widget.stop,
      routesById: demoRoutesById,
      now: now,
      limit: 12,
    );
    return Scaffold(
      appBar: AppBar(title: Text(widget.stop.name)),
      body: arrivals.isEmpty
          ? const Center(child: Text('No more departures today.'))
          : ListView.separated(
              itemCount: arrivals.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final arrival = arrivals[index];
                final mins = arrival.minutesAway(now);
                return ListTile(
                  leading: RouteDot(route: arrival.route),
                  title: Text(arrival.route.longName),
                  subtitle: Text('Departs ${_formatTime(arrival.departsAt)}'),
                  trailing: Text(
                    mins <= 0 ? 'Due' : '$mins min',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: mins <= 2
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ),
                  ),
                );
              },
            ),
    );
  }
}
