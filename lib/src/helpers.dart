import 'dart:math' as dart_math;

import 'package:big_double/src/shared.dart';

export "package:big_double/src/shared.dart";

/// Reports whether whatever application is bundled is running via the JavaScript runtime.
bool get isJavaScript => identical(1.0, 1);

/// Some random extensions for dealing with numbers.
extension HelpfulNum on num {
  /// Whether this [num] is positive (greater than 0)
  bool get isPositive => this > 0;

  /// Whether this [num] is zero (equal to 0)
  bool get isZero => this is double ? this < roundTolerance : this == 0;
}

/// Much of the functions perfom much worse in accuracy over time as compared
/// to other low level implementations like C# and Java's Stricter math implementations
/// for native platforms.
class CasualNumerics {
  CasualNumerics._();

  /// Returns the base 10 logarithm of this [num] instance.
  static double log10(num x) => dart_math.log(x) / dart_math.ln10;

  static bool isSafe(num x) {
    return x.abs() < 9007199254740991 && x.floor() == x;
  }

  /// Returns whether [a] and [b] are within
  static bool isEquatable(double a, double b, {double tolerance = roundTolerance}) {
    return (a - b).abs() < tolerance;
  }

  /// Checks whether [value] is an integer value
  static bool isInt(dynamic value) {
    return value is int && value is double
        ? value.isInfinite || value.isNaN || value.abs() > (1 << 53)
            ? false
            : value.truncateToDouble() == value
        : false;
  }
}

final class ZeroStringInterner {
  ZeroStringInterner._();

  static final Map<int, String> _cache = <int, String>{};

  static String poke(int counts) {
    if (counts <= 0) {
      return "";
    } else if (!_cache.containsKey(counts)) {
      _cache[counts] = "0" * counts;
      return _cache[counts]!;
    }
    return _cache[counts]!;
  }
}

String trailZeroes(int places) {
  return places > 0 ? "." + ZeroStringInterner.poke(places) : "";
}
