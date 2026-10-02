import 'package:flutter/material.dart';
import '../data/demo_schedule.dart';
import '../models/stop.dart';

/// Bottom sheet listing every demo stop the user hasn't saved yet.
class AddStopSheet extends StatelessWidget {
  const AddStopSheet({
    super.key,
    required this.savedIds,
    required this.onAdd,
  });

  final Set<String> savedIds;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    final available =
        demoStops.where((s) => !savedIds.contains(s.id)).toList();
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Add a stop',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          if (available.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('All demo stops are already saved.'),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: available.length,
                itemBuilder: (context, index) {
                  final stop = available[index];
                  return ListTile(
                    title: Text(stop.name),
                    subtitle: Text(_routeSummary(stop)),
                    trailing: const Icon(Icons.add),
                    onTap: () => onAdd(stop.id),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _routeSummary(Stop stop) => stop.routeIds
      .map((id) => demoRoutesById[id]?.shortName ?? id)
      .join(' · ');
}
