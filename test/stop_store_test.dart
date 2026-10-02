import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:transittrack/services/stop_store.dart';

void main() {
  late Directory dir;
  late StopStore store;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('transittrack_store_test');
    store = StopStore(directoryProvider: () async => dir);
  });

  tearDown(() async {
    await dir.delete(recursive: true);
  });

  group('StopStore', () {
    test('starts empty with the default lead time', () async {
      expect(await store.savedStopIds(), isEmpty);
      expect(
        await store.leadTimeMinutes(),
        StopStore.defaultLeadTimeMinutes,
      );
    });

    test('round-trips saved stops in order', () async {
      await store.saveStopIds(['a', 'b', 'c']);
      expect(await store.savedStopIds(), ['a', 'b', 'c']);
    });

    test('persists a reorder', () async {
      await store.saveStopIds(['a', 'b', 'c']);
      await store.saveStopIds(['c', 'a', 'b']);
      expect(await store.savedStopIds(), ['c', 'a', 'b']);
    });

    test('persists a removal', () async {
      await store.saveStopIds(['a', 'b']);
      await store.saveStopIds(['a']);
      expect(await store.savedStopIds(), ['a']);
    });

    test('round-trips the lead time without losing saved stops', () async {
      await store.saveStopIds(['a']);
      await store.setLeadTimeMinutes(20);

      expect(await store.leadTimeMinutes(), 20);
      expect(await store.savedStopIds(), ['a']);
    });

    test('a second store instance sees the same file', () async {
      await store.saveStopIds(['x']);
      final other = StopStore(directoryProvider: () async => dir);
      expect(await other.savedStopIds(), ['x']);
    });
  });
}
