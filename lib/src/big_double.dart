import 'dart:math';

import 'package:break_infinity/src/powers_of_10.dart';
import 'package:break_infinity/src/src.dart';

class BigDouble implements Comparable<BigDouble> {
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
            ? (value.isPositive ? infinity : negativeInfinity)
            : value.isZero
                ? zero
                : _normalize(value, 0);
  }

  BigDouble(double mantissa, int exponent) {
    BigDouble normalized = _normalize(mantissa, exponent);
    _mantissa = normalized._mantissa;
    _exponent = normalized._exponent;
  }

  /// Whether this [BigDouble] instance is infinite.
  bool get isInfinity => _mantissa.isInfinite;

  bool get isPositiveInfinity => _mantissa.isPositive && isInfinity;

  bool get isNegativeInfinity => _mantissa.isNegative && isInfinity;

  /// Whether this [BigDouble] instance is finite.
  bool get isFinite => _mantissa.isFinite;

  /// Whether this [BigDouble] instance is Not a Number.
  bool get isNaN => _mantissa.isNaN;

  bool _sameInfinity(BigDouble other) {
    return (isPositiveInfinity && other.isPositiveInfinity) ||
        (isNegativeInfinity && other.isNegativeInfinity);
  }

  @override
  bool operator ==(Object other) {
    return equalsWithTolerance(other);
  }

  /// Called by for [operator ==] with the default tolerance in [roundTolerance]
  ///
  /// If you don't want tolerance checking, use [BigDouble.equalsRaw]
  bool equalsWithTolerance(Object other, [double tolerance = roundTolerance]) {
    return other is BigDouble &&
        !isNaN &&
        !other.isNaN &&
        (_sameInfinity(other) ||
            _exponent == other._exponent && (_mantissa - other._mantissa) < tolerance);
  }

  /// Does no tolerance checking as compared to [BigDouble.==] or [BigDouble.equalsWithTolerance]
  bool equalsRaw(Object other) {
    return other is BigDouble &&
        _mantissa == other._mantissa &&
        _exponent == other._exponent;
  }

  bool operator >(BigDouble other) {
    return isNaN || other.isNaN
        ? false
        : _mantissa.isZero
            ? other._mantissa.isNegative
            : other._mantissa.isZero
                ? _mantissa.isPositive
                : _exponent == other._exponent
                    ? _mantissa > other._mantissa
                    : _mantissa.isPositive
                        ? (other._mantissa.isNegative || _exponent > other._exponent)
                        : _exponent < other._exponent &&
                            other._mantissa
                                .isNegative; // never catch me using if statements
  }

  bool operator <(BigDouble other) {
    return isNaN || other.isNaN
        ? false
        : _mantissa.isZero
            ? other._mantissa.isPositive
            : other._mantissa.isZero
                ? _mantissa.isNegative
                : _exponent == other._exponent
                    ? _mantissa < other._mantissa
                    : _mantissa.isPositive
                        ? (other._mantissa.isPositive && _exponent < other._exponent)
                        : _exponent > other._exponent ||
                            other._mantissa
                                .isPositive; // never catch me using if statements
  }

  bool operator >=(BigDouble other) {
    return isNaN || other.isNaN ? false : !(this < other);
  }

  bool operator <=(BigDouble other) {
    return isNaN || other.isNaN ? false : !(this > other);
  }

  BigDouble operator -() {
    _mantissa = -_mantissa;
    return this;
  }

  BigDouble operator -(BigDouble other) {
    return this + -other;
  }

  BigDouble operator +(BigDouble other) {
    if (isInfinity) {
      return this;
    } else if (other.isInfinity) {
      return other;
    } else if (_mantissa.isZero) {
      return other;
    } else if (other._mantissa.isZero) {
      return this;
    }
    late BigDouble bigger;
    late BigDouble smaller;
    if (_exponent > other._exponent) {
      bigger = this;
      smaller = other;
    } else {
      bigger = other;
      smaller = this;
    }
    return bigger._exponent - smaller._exponent > maxSignificantDigits
        ? bigger
        : _normalize(
            1e14 * bigger._mantissa +
                (1e14 *
                    smaller._mantissa *
                    lookupPowerOf10(smaller._exponent - bigger._exponent).round()),
            bigger._exponent - 14);
  }

  @override
  int compareTo(covariant BigDouble other) {
    return _mantissa.isZero ||
            other._mantissa.isZero ||
            isNaN ||
            other.isNaN ||
            isInfinity ||
            other.isInfinity
        ? _mantissa.compareTo(other._mantissa)
        : _mantissa.isPositive && other._mantissa.isNegative
            ? 1
            : _mantissa.isNegative && other._mantissa.isPositive
                ? -1
                : () {
                    int c = _exponent.compareTo(other._exponent);
                    return c != 0
                        ? (_mantissa.isPositive ? c : -c)
                        : _mantissa.compareTo(other._mantissa);
                  }(); // TODO: maybe reimplement all of this jargon using if statements lol
  }
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
