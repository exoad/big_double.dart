import 'dart:math' as dart_math;

export "package:break_infinity/src/native/shared.dart"
    if (dart.library.js_interop) "package:break_infinity/src/web/shared.dart";

extension HelpfulDouble on double {
  /// Represents the smallest positive [double] value that is greater than 0.
  static const double epsilon = 4.94065645841247e-324;
}

extension HelpfulNum on num {
  /// Whether this [num] is positive (greater than 0)
  bool get isPositive => this > 0;

  /// Whether this [num] is zero (equal to 0)
  bool get isZero => this == 0;

  /// Whether this [num] is odd
  bool get isOdd => this % 2 != 0;

  /// Whether this [num] is even
  bool get isEvent => !isOdd;
}

/// Much of the functions perfom much worse in accuracy over time as compared
/// to other low level implementations like C# and Java's Stricter math implementations
/// for native platforms.
class CasualNumerics {
  CasualNumerics._();

  /// Returns the base 10 logarithm of this [num] instance.
  static double log10(num x) => dart_math.log(x) / dart_math.ln10;
}
