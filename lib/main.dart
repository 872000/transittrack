import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'services/stop_store.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = StopStore(
    directoryProvider: () async {
      if (Platform.isAndroid || Platform.isIOS) {
        return getApplicationDocumentsDirectory();
      }
      // Desktop demo: keep the JSON file next to the working directory.
      return Directory.current;
    },
  );
  runApp(TransitTrackApp(store: store));
}
