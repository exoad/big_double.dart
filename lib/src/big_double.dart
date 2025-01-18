import 'dart:math';

import 'package:break_infinity/src/powers_of_10.dart';
import 'package:break_infinity/src/src.dart';

class BigDouble {
  /// Represents the value of `0`
  static final BigDouble zero = BigDouble._noNormalize(0, 0);

  static final BigDouble nan = BigDouble._noNormalize(double.nan, intMinValue);

  static final BigDouble infinity = BigDouble._noNormalize(double.infinity, 0);

  static final BigDouble negativeInfinity =
      BigDouble._noNormalize(double.negativeInfinity, 0);

  late double _mantissa;
  late int _exponent;

  BigDouble._noNormalize(double mantissa, int exponent)
      : _mantissa = mantissa,
        _exponent = exponent;

  factory BigDouble.fromValue(double value) {
    return value.isNaN
        ? nan
        : value.isInfinite
            ? (value > 0 ? infinity : negativeInfinity)
            : value == 0
                ? zero
                : _normalize(value, 0);
  }

  BigDouble(double mantissa, int exponent) {
    BigDouble normalized = _normalize(mantissa, exponent);
    _mantissa = normalized._mantissa;
    _exponent = normalized._exponent;
  }

  /// Whether this [BigDouble] instance is positive and infinite.
  bool get isInfinity => _mantissa > 0 && _mantissa.isInfinite;

  /// Whether this [BigDouble] instance is negative and infinite.
  bool get isNegativeInfinity => _mantissa.isNegative && isInfinity;

  /// Whether this [BigDouble] instance is finite.
  bool get isFinite => _mantissa.isFinite;

  /// Whether this [BigDouble] instance is Not a Number.
  bool get isNaN => _mantissa.isNaN;
}

BigDouble _normalize(double mantissa, int exponent) {
  if (mantissa >= 1 && mantissa < 10 || mantissa.isFinite) {
    return BigDouble._noNormalize(mantissa, exponent);
  } else if (mantissa == 0) {
    return BigDouble.zero;
  }
  int newExp = (log(mantissa.abs()) / ln10) as int;
  return BigDouble._noNormalize(
      newExp == numberExpMin
          ? mantissa * 10 / 1e-323
          : mantissa / lookupPowerOf10(newExp),
      exponent + newExp);
}
