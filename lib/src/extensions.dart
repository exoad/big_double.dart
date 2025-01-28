import 'package:big_double/src/impl_1.dart';

/// A simplified version of using [BigDouble] by just calling a simple getter
/// methods [IntBigDoublify.big]
extension IntBigDoublify on int {
  /// Converts this [int] instance to a [BigDouble] instance.
  /// Usage:
  /// ```dart
  /// var bigBigBig = 3.big;
  /// ```
  BigDouble get big => switch (this) {
        0 => BigDouble.zero,
        1 => BigDouble.one,
        _ => BigDouble.fromValue(this.roundToDouble())
      };
}

/// A simplified version of using [BigDouble] by just calling a simple getter
/// methods [NumBigDoublify.big]
extension NumBigDoublify on num {
  BigDouble get big => switch (this) {
        0 => BigDouble.zero,
        1 => BigDouble.one,
        _ => BigDouble.fromValue(this.toDouble())
      };
}

/// Converts a tuple in the form of `(double,int)` where the first element
/// of [double] is the mantissa and the second element of [int] is the
/// exponent into a [BigDouble] instance.
/// Note: that this does not return any of the [BigDouble.one] or [BigDouble.zero]
/// instances as covering these cases is futile.
extension Tuple1BigDoublify on (
  double /*mantissa*/,
  int
  /*exponent*/
) {
  /// Converts this tuple to an appropriate [BigDouble] instance
  BigDouble get big => BigDouble(this.$1, this.$2);
}

/// Same as [Tuple1BigDoublify] but the first element is of type int.
extension Tuple2BigDoublify on (int, int) {
  /// Converts this tuple to an appropriate [BigDouble] instance
  BigDouble get big => BigDouble(this.$1.toDouble(), this.$2);
}

/// A simplified version of using [BigDouble] by just calling a simple getter
/// methods [DoubleBigDoublify.big]
extension DoubleBigDoublify on double {
  /// Converts this [double] instance to a [BigDouble] instance.
  /// Usage:
  /// ```dart
  /// var bigBigBig = (3.0).big;
  /// ```
  BigDouble get big => isNaN
      ? BigDouble.nan
      : switch (this) {
          0 => BigDouble.zero,
          1 => BigDouble.one,
          double.infinity => BigDouble.infinity,
          double.negativeInfinity => BigDouble.negativeInfinity,
          _ => BigDouble.fromValue(this)
        };
}

/// A simplified version of using [BigDouble] on Strings
extension StringBigDoublify on String {
  /// Uses [BigDouble.tryParse] to obtain value
  BigDouble get tryParseBigDouble => BigDouble.tryParse(this);

  /// Uses [BigDouble.parse] to obtain value
  BigDouble get parseBigDouble => BigDouble.parse(this);
}
