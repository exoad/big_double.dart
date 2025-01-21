import 'dart:math' as dart_math;

import 'package:break_infinity/src/shared.dart';

export "package:break_infinity/src/shared.dart";

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

  static bool isSafe(double x) {
    return isJavaScript
        ? x > -9007199254740991 && x < 9007199254740991 && x.floor() == x
        : x.isZero;
  }
}
