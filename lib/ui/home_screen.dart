import 'dart:async';

import 'package:flutter/material.dart';

import '../data/demo_schedule.dart';
import '../models/arrival.dart';
import '../models/service_notice.dart';
import '../models/stop.dart';
import '../services/arrival_engine.dart';
import '../services/clock.dart';
import '../services/reminder_service.dart';
import '../services/stop_store.dart';
import 'add_stop_sheet.dart';
import 'stop_detail_screen.dart';
import 'widgets/route_dot.dart';

/// Saved-stops list: add, remove (swipe action via trailing button), and
/// reorder via drag. Shows the next departure per stop and fires "leave now"
/// reminders on a timer.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.store,
    required this.clock,
    this.refreshInterval = const Duration(seconds: 30),
  });

  final StopStore store;
  final Clock clock;
  final Duration refreshInterval;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _engine = const ArrivalEngine();
  final _reminders = const ReminderService();

  List<String> _savedIds = [];
  int _leadMinutes = StopStore.defaultLeadTimeMinutes;
  bool _loading = true;
  Timer? _timer;
  final _seenReminderIds = <String>{};

  @override
  void initState() {
    super.initState();
    _load();
    if (widget.refreshInterval > Duration.zero) {
      _timer = Timer.periodic(widget.refreshInterval, (_) => _tick());
    }
  }

  Future<void> _load() async {
    final ids = await widget.store.savedStopIds();
    final lead = await widget.store.leadTimeMinutes();
    if (!mounted) return;
    setState(() {
      _savedIds = ids;
      _leadMinutes = lead;
      _loading = false;
    });
    _tick();
  }

  /// Re-evaluates countdowns and raises "leave now" reminders.
  void _tick() {
    if (!mounted || _loading) return;
    final now = widget.clock.now();
    final lead = Duration(minutes: _leadMinutes);
    for (final stop in _savedStops) {
      final arrivals = _engine.upcoming(
        stop: stop,
        routesById: demoRoutesById,
        now: now,
      );
      final due = _reminders.due(
        arrivals: arrivals,
        now: now,
        leadTime: lead,
        acknowledgedIds: _seenReminderIds,
      );
      if (due.isNotEmpty) {
        _seenReminderIds.addAll(due.map((r) => r.id));
        final first = due.first;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${first.title}: ${first.body}')),
        );
        break; // one nudge per tick keeps the UI calm
      }
    }
    setState(() {});
  }

  List<Stop> get _savedStops => [
        for (final id in _savedIds)
          ...demoStops.where((s) => s.id == id),
      ];

  Future<void> _persist() => widget.store.saveStopIds(_savedIds);

  void _addStop(String id) {
    setState(() => _savedIds = [..._savedIds, id]);
    _persist();
  }

  void _removeStop(String id) {
    setState(() => _savedIds = _savedIds.where((s) => s != id).toList());
    _persist();
  }

  void _openAddSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => AddStopSheet(
        savedIds: _savedIds.toSet(),
        onAdd: (id) {
          Navigator.pop(context);
          _addStop(id);
        },
      ),
    );
  }

  Future<void> _openSettings() async {
    var value = _leadMinutes;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reminder settings'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Alert me $value minutes before departure'),
              Slider(
                value: value.toDouble(),
                min: 5,
                max: 30,
                divisions: 5,
                label: '$value min',
                onChanged: (v) => setDialogState(() => value = v.round()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved == true && mounted) {
      setState(() => _leadMinutes = value);
      await widget.store.setLeadTimeMinutes(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stops = _savedStops;
    return Scaffold(
      appBar: AppBar(
        title: const Text('TransitTrack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Reminder settings',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (demoNotices.isNotEmpty) const _NoticeBanner(),
                Expanded(
                  child: stops.isEmpty
                      ? _EmptyState(onAdd: _openAddSheet)
                      : ReorderableListView.builder(
                          itemCount: stops.length,
                          onReorderItem: (oldIndex, newIndex) {
                            setState(() {
                              final id = _savedIds.removeAt(oldIndex);
                              _savedIds.insert(newIndex, id);
                            });
                            _persist();
                          },
                          itemBuilder: (context, index) {
                            final stop = stops[index];
                            return _StopTile(
                              key: ValueKey(stop.id),
                              stop: stop,
                              now: widget.clock.now(),
                              engine: _engine,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StopDetailScreen(
                                    stop: stop,
                                    clock: widget.clock,
                                  ),
                                ),
                              ),
                              onRemove: () => _removeStop(stop.id),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        icon: const Icon(Icons.add),
        label: const Text('Add stop'),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class _StopTile extends StatelessWidget {
  const _StopTile({
    super.key,
    required this.stop,
    required this.now,
    required this.engine,
    required this.onTap,
    required this.onRemove,
  });

  final Stop stop;
  final DateTime now;
  final ArrivalEngine engine;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final next = engine.upcoming(
      stop: stop,
      routesById: demoRoutesById,
      now: now,
      limit: 1,
    );
    final subtitle =
        next.isEmpty ? 'No more departures today' : _describe(next.first);
    return ListTile(
      title: Text(stop.name),
      subtitle: Text(subtitle),
      leading: next.isEmpty
          ? const Icon(Icons.directions_bus_outlined)
          : RouteDot(route: next.first.route),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Remove stop',
        onPressed: onRemove,
      ),
      onTap: onTap,
    );
  }

  String _describe(Arrival arrival) {
    final mins = arrival.minutesAway(now);
    final when = mins <= 0 ? 'Due now' : 'in $mins min';
    return '${arrival.route.shortName} · $when';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.directions_transit, size: 64),
            const SizedBox(height: 16),
            const Text(
              'No saved stops yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Save the stops you use every day and TransitTrack will '
              'count down the next departures for you — no network needed.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add your first stop'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoticeBanner extends StatelessWidget {
  const _NoticeBanner();

  @override
  Widget build(BuildContext context) {
    final notice = demoNotices.first;
    final color = switch (notice.severity) {
      NoticeSeverity.critical => Colors.red,
      NoticeSeverity.warning => Colors.orange,
      NoticeSeverity.info => Colors.blue,
    };
    return Container(
      width: double.infinity,
      color: color.withValues(alpha: 0.12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              notice.title,
              style:
                  TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
