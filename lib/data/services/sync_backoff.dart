import 'dart:math';

class SyncBackoff {
  static const List<int> defaultIntervals = [2, 5, 15, 60, 300]; // in seconds

  /// Returns delay in seconds for the given attempt count (0-indexed).
  /// Exponential backoff capped at 300 seconds (5 minutes).
  static int getDelaySeconds(int attemptCount) {
    if (attemptCount < 0) return defaultIntervals.first;
    if (attemptCount >= defaultIntervals.length) return defaultIntervals.last;
    return defaultIntervals[attemptCount];
  }

  /// Calculates duration for the retry attempt.
  static Duration getDelayDuration(int attemptCount) {
    return Duration(seconds: getDelaySeconds(attemptCount));
  }
}
