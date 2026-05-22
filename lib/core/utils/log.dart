import 'package:flutter/foundation.dart';

/// Production-safe debug logging.
///
/// - Uses [debugPrint] to avoid log truncation/throttling issues.
/// - No-ops in release/profile builds.
void logD(Object? message) {
  if (kDebugMode) {
    debugPrint(message?.toString() ?? 'null');
  }
}

