/// Abstraction over "what time is it" so arrival math can be tested with a
/// fixed clock instead of the real one.
abstract class Clock {
  DateTime now();
}

/// Production clock: the real current time.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// Test clock: always returns the same instant.
class FixedClock implements Clock {
  const FixedClock(this.fixed);

  final DateTime fixed;

  @override
  DateTime now() => fixed;
}
