import 'package:flutter_test/flutter_test.dart';
import 'package:transittrack/services/clock.dart';
import 'package:transittrack/services/stop_store.dart';
import 'package:transittrack/ui/app.dart';

/// In-memory [StopStore] so widget tests never touch the filesystem
/// (dart:io file calls do not complete inside testWidgets' fake-async zone).
class FakeStopStore extends StopStore {
  FakeStopStore({List<String> savedIds = const []})
      : _savedIds = List.of(savedIds),
        super(directoryProvider: () => throw UnimplementedError());

  final List<String> _savedIds;
  int _leadMinutes = StopStore.defaultLeadTimeMinutes;

  @override
  Future<List<String>> savedStopIds() async => List.of(_savedIds);

  @override
  Future<void> saveStopIds(List<String> ids) async {
    _savedIds
      ..clear()
      ..addAll(ids);
  }

  @override
  Future<int> leadTimeMinutes() async => _leadMinutes;

  @override
  Future<void> setLeadTimeMinutes(int minutes) async {
    _leadMinutes = minutes;
  }
}

void main() {
  testWidgets('saved stop shows its next arrival', (tester) async {
    await tester.pumpWidget(
      TransitTrackApp(
        store: FakeStopStore(savedIds: ['queen_spadina']),
        // Friday noon: 501 Queen runs every 10 min 09:00–15:00.
        clock: FixedClock(DateTime(2026, 10, 2, 12, 0)),
        refreshInterval: Duration.zero, // no periodic timer in tests
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Queen St W / Spadina Ave'), findsOneWidget);
    // The next-arrival summary mentions a route serving the stop.
    expect(find.textContaining('501'), findsWidgets);
  });

  testWidgets('empty state invites the user to add a stop', (tester) async {
    await tester.pumpWidget(
      TransitTrackApp(
        store: FakeStopStore(),
        clock: FixedClock(DateTime(2026, 10, 2, 12, 0)),
        refreshInterval: Duration.zero,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No saved stops yet'), findsOneWidget);
    expect(find.text('Add your first stop'), findsOneWidget);
  });
}
