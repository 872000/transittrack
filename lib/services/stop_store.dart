import 'dart:convert';
import 'dart:io';

/// Persists the user's saved stops and reminder preference as a small JSON
/// file. The directory is injectable so tests can point it at a temp dir.
class StopStore {
  StopStore({required this.directoryProvider});

  final Future<Directory> Function() directoryProvider;

  static const String fileName = 'transittrack.json';
  static const int defaultLeadTimeMinutes = 10;

  Future<File> _file() async {
    final dir = await directoryProvider();
    return File('${dir.path}/$fileName');
  }

  Future<Map<String, dynamic>> _read() async {
    try {
      final file = await _file();
      if (!await file.exists()) return <String, dynamic>{};
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<void> _write(Map<String, dynamic> data) async {
    final file = await _file();
    await file.writeAsString(jsonEncode(data));
  }

  /// Saved stop ids in the user's chosen order.
  Future<List<String>> savedStopIds() async {
    final data = await _read();
    final raw = data['savedStopIds'];
    if (raw is List) return raw.whereType<String>().toList();
    return <String>[];
  }

  Future<void> saveStopIds(List<String> ids) async {
    final data = await _read();
    data['savedStopIds'] = ids;
    await _write(data);
  }

  /// Minutes before departure at which "leave now" alerts fire.
  Future<int> leadTimeMinutes() async {
    final data = await _read();
    final raw = data['leadTimeMinutes'];
    if (raw is int && raw > 0) return raw;
    return defaultLeadTimeMinutes;
  }

  Future<void> setLeadTimeMinutes(int minutes) async {
    final data = await _read();
    data['leadTimeMinutes'] = minutes;
    await _write(data);
  }
}
