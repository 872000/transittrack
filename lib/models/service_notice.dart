/// Severity of a service notice, worst first.
enum NoticeSeverity { critical, warning, info }

/// A service-status notice from the bundled offline data feed.
class ServiceNotice {
  const ServiceNotice({
    required this.id,
    required this.title,
    required this.body,
    required this.severity,
    this.routeIds = const <String>[],
  });

  final String id;
  final String title;
  final String body;
  final NoticeSeverity severity;

  /// Empty means network-wide.
  final List<String> routeIds;
}
