export "package:break_infinity/src/native/shared.dart"
    if (dart.library.js_interop) "package:break_infinity/src/web/shared.dart";

extension HelpfulNum on num {
  /// Whether this [num] is positive (greater than 0)
  bool get isPositive => this > 0;

  /// Whether this [num] is zero (equal to 0)
  bool get isZero => this == 0;
}
