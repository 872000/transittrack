/// A transit stop served by one or more routes.
class Stop {
  const Stop({
    required this.id,
    required this.name,
    this.description = '',
    required this.routeIds,
  });

  final String id;
  final String name;
  final String description;

  /// Ids of [TransitRoute]s that serve this stop.
  final List<String> routeIds;
}
