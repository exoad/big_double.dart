import 'dart:math' as dart_math;

import 'package:break_infinity/src/powers_of_10.dart';
import 'package:break_infinity/src/helpers.dart';

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
  BigDouble get big => this.isNaN
      ? BigDouble.nan
      : switch (this) {
          0 => BigDouble.zero,
          1 => BigDouble.one,
          double.infinity => BigDouble.infinity,
          double.negativeInfinity => BigDouble.negativeInfinity,
          _ => BigDouble.fromValue(this)
        };
}

/// Additional helper functions for using [BigDouble]. These functions are things like
/// [BigDouble.max] and others which operate on multiple [BigDouble] instances.
/// Think of it like the "dart:math" module. Furthermore, some of these functions are also
/// used inside of [BigDouble] itself.
final class BigMath {
  BigMath._();

  /// Returns the max of two [BigDouble] instances.
  static BigDouble max(BigDouble a, BigDouble b) {
    return a.isNaN || b.isNaN
        ? BigDouble.nan
        : a > b
            ? a
            : b;
  }

  /// Returns the min of two [BigDouble] instances.
  static BigDouble min(BigDouble a, BigDouble b) {
    return a.isNaN || b.isNaN
        ? BigDouble.nan
        : a > b
            ? b
            : a;
  }

  /// Performs a square root on the [BigDouble] instance.
  /// If the argument is NaN or less than zero, this function will return [BigDouble.nan].
  static BigDouble sqrt(BigDouble value) {
    return value._mantissa.isNegative
        ? BigDouble.nan
        : value._exponent.isOdd
            ? _normalize(dart_math.sqrt(value._mantissa) * 3.16227766016838,
                (value._exponent - 1) ~/ 2)
            : _normalize(dart_math.sqrt(value._mantissa), value._exponent ~/ 2);
  }

  /// Log base 10. Utilizes a vary rough calculation from [CasualNumerics]
  static double log10(BigDouble value) {
    return value._exponent * CasualNumerics.log10(value._mantissa);
  }

  /// Returns the log of [value]
  static double log(BigDouble value) {
    return 2.302585092994046 * log10(value);
  }
}

/// For either debugging or looking into the two core values within a [BigDouble] instance.
/// Some of these functions can be dangerous and introduce unpredictable behavior.
final class BigDoubleIntrospect {
  BigDoubleIntrospect._();

  /// Gets the mantissa value
  static double mantissa(BigDouble value) => value._mantissa;

  /// Gets the exponent value
  static int exponent(BigDouble value) => value._exponent;

  /// **DESTRUCTIVE ACTION**
  /// Changes [value]'s mantissa to [newValue]
  static void changeMantissa(BigDouble value, double newValue) {
    value._mantissa = newValue;
  }

  /// **DESTRUCTIVE ACTION**
  /// Changes [value]'s exponent to [newValue]
  static void changeExponent(BigDouble value, int newValue) {
    value._exponent = newValue;
  }
}

/// The break_infinity implementation in Dart. This is capable of exceeding 1e308 and is based
/// on Patashu's break_infinity.js implementation. https://patashu.github.io/break_infinity.js/index.html
/// As compared to Dart's own [BigInt] which sacrifices speed and performance over time
/// for accuracy, [BigDouble] focuses on sacrificing accuracy over time for far better
/// performance (10-1000x) with a "good enough estimation". For this reason, it is very useful for creating incremental games or other quantities that do not need high accuracies at large magnitudes.
class BigDouble implements Comparable<BigDouble> {
  /// Used for internal operations
  static final dart_math.Random _random =
      dart_math.Random(DateTime.now().millisecondsSinceEpoch);

  /// Represents the value of `0`
  static final BigDouble zero = BigDouble._noNormalize(0, 0);

  /// Represents the unit value of `1`
  static final BigDouble one = BigDouble._noNormalize(1, 0);

  /// Repressents a [BigDouble] that is Not a Number using [double.nan]
  static final BigDouble nan = BigDouble._noNormalize(double.nan, intMinValue);

  /// Represents positive infinity for this [BigDouble] instance utilizing [double.infinity]
  static final BigDouble infinity = BigDouble._noNormalize(double.infinity, 0);

  /// Represents negative infinity for this [BigDouble] instance utilizing [double.negativeInfinity]
  static final BigDouble negativeInfinity =
      BigDouble._noNormalize(double.negativeInfinity, 0);

  /// Represents the signficant digits in this [BigDouble]
  late double _mantissa;

  /// Determines how the decimal point should move.
  late int _exponent;

  BigDouble._noNormalize(double mantissa, int exponent)
      : _mantissa = mantissa,
        _exponent = exponent;

  /// Generates a [BigDouble] instance with the provided [double] value.
  factory BigDouble.fromValue(double value) {
    return value.isNaN
        ? nan
        : value.isInfinite
            ? (value.isPositive ? infinity : negativeInfinity)
            : value.isZero
                ? zero
                : _normalize(value, 0);
  }

  /// Parses a [BigDouble] from a String literal. If it is not recognizable using the exponential
  /// format, this constructor will throw a [FormatException].
  /// If you don't want exceptions, prefer using [BigDouble.tryParse]
  factory BigDouble.parse(String value) /*throws Exception*/ {
    if (value.indexOf("e") != -1) {
      List<String> parts = value.split("e");
      return _normalize(double.parse(parts[0]), int.parse(parts[1]));
    } else if (value == "NaN") {
      return nan;
    }
    BigDouble res = BigDouble.fromValue(double.parse(value));
    if (res.isNaN) {
      throw FormatException("Failed to initialize a BigDouble with $value");
    }
    return res;
  }

  /// Similar to [BigDouble.parse] but does not throw a [FormatException] on an invalid
  /// String literal. It will just return [BigDouble.nan].
  factory BigDouble.tryParse(String value) {
    if (value.indexOf("e") != -1) {
      List<String> parts = value.split("e");
      return _normalize(double.parse(parts[0]), int.parse(parts[1]));
    } else if (value == "NaN") {
      return nan;
    }
    BigDouble res = BigDouble.fromValue(double.parse(value));
    if (res.isNaN) {
      return nan;
    }
    return res;
  }

  /// Given a [mantissaMax] and [exponentMax], generate a random [BigDouble] instance
  factory BigDouble.random({int mantissaMax = 100, int exponentMax = 10}) {
    return BigDouble._noNormalize(
        _random.nextDouble() * mantissaMax, _random.nextInt(exponentMax));
  }

  /// Constructs a [BigDouble] instance with the given mantissa and exponent.
  ///
  ///
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
    return isPositiveInfinity && other.isPositiveInfinity ||
        isNegativeInfinity && other.isNegativeInfinity;
  }

  /// Returns the sign of this [BigDouble]
  double get sign => _mantissa.sign;

  @override
  bool operator ==(covariant Object other) {
    return equalsWithTolerance(other);
  }

  /// If you don't want tolerance checking, use [BigDouble.equalsRaw]
  bool equalsWithTolerance(covariant Object other, [double tolerance = roundTolerance]) {
    return other is BigDouble &&
        !isNaN &&
        !other.isNaN &&
        (_sameInfinity(other) ||
            _exponent == other._exponent && (_mantissa - other._mantissa) < tolerance);
  }

  /// Equality checking without using tolerance. If you need tolerance, use [BigDouble.equalsWithTolerance]
  bool equalsRaw(covariant Object other) {
    return other is BigDouble &&
        _mantissa == other._mantissa &&
        _exponent == other._exponent;
  }

  /// Some additional checks used internally by all comparison operators
  bool _comparisonPreCheck(BigDouble other) {
    return !(isNaN || other.isNaN);
  }

  /// If this [BigDouble] is greater than [other]
  bool operator >(BigDouble other) {
    return _comparisonPreCheck(other) && compareTo(other) > 0;
  }

  /// If this [BigDouble] is less than [other]
  bool operator <(BigDouble other) {
    return _comparisonPreCheck(other) &&
        compareTo(other) < 0; // never catch me using if statements
  }

  /// If this [BigDouble] is greater than or equal to [other]
  bool operator >=(BigDouble other) {
    return _comparisonPreCheck(other) && compareTo(other) >= 0;
  }

  /// If this [BigDouble] is less than or equal to [other]
  bool operator <=(BigDouble other) {
    return _comparisonPreCheck(other) && compareTo(other) <= 0;
  }

  int _compareToHelper(covariant BigDouble other) {
    int c = _exponent.compareTo(other._exponent);
    return c != 0
        ? (_mantissa.isPositive ? c : -c)
        : _mantissa.compareTo(other._mantissa);
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
                : _compareToHelper(other);
  }

  /// Negate this [BigDouble]
  BigDouble operator -() {
    return BigDouble(-_mantissa,
        _exponent); // we have to return a new value to avoid modifying the globals
  }

  /// Multiplies this [BigDouble] with [other]; multiplication.
  BigDouble operator *(BigDouble other) {
    return _normalize(_mantissa * other._mantissa, _exponent + other._exponent);
  }

  /// Get the multiplicative inverse (reciprocal) of this [BigDouble]
  BigDouble get reciprocal => _normalize(1 / _mantissa, -_exponent);

  /// Divides this [BigDouble] with [other]; division.
  /// Under the hood it calls [BigDouble.*]
  BigDouble operator /(BigDouble other) {
    return this * other.reciprocal;
  }

  /// Subtracts this [BigDouble] with [other]; subtraction.
  /// Under the hood it calls [BigDouble.+]
  BigDouble operator -(BigDouble other) {
    return this + -other;
  }

  /// Adds this [BigDouble] with [other]; addition.
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

  /// Returns a [BigDouble] instance that is the absolute value of this [BigDouble].
  BigDouble get abs => BigDouble._noNormalize(_mantissa.abs(), _exponent);

  /// Computes the largest [BigDouble] value that is less than or equal to `this` and is equal
  /// to a mathematical integer. Can return `this`.
  /// If the value is [nan] or [isInfinity], then the same value is returned.
  BigDouble get floor {
    if (isInfinity) {
      return this;
    } else if (_exponent < -1) {
      return _mantissa.sign >= 0 ? zero : -one;
    } else if (_exponent < maxSignificantDigits) {
      return BigDouble.fromValue(toDouble().floorToDouble());
    }
    return this;
  }

  @override
  int get hashCode => (_mantissa.hashCode * 397) ^ _exponent.hashCode;

  /// Converts this [BigDouble] instance to a double with [tolerance] to an exact integer if possible.
  /// If `this` is too big, it will return infinity.
  /// If `this` is too small, it will return 0.
  double toDouble([double tolerance = roundTolerance]) {
    if (isNaN) {
      return double.nan;
    } else if (_exponent > numberExpMax) {
      return _mantissa.isPositive ? double.infinity : double.negativeInfinity;
    } else if (_exponent < numberExpMin) {
      return 0.0;
    } else if (_exponent == numberExpMin) {
      return _mantissa > 0 ? 5e-324 : -5e-324;
    }
    double res = _mantissa * lookupPowerOf10(_exponent);
    if (!res.isFinite || _exponent < 0) {
      return res;
    }
    double rounded = res.roundToDouble();
    return (rounded - res).abs() < roundTolerance ? rounded : res;
  }
}

/// Internal function
BigDouble _normalize(double mantissa, int exponent) {
  if (mantissa >= 1 && mantissa < 10 || mantissa.isFinite) {
    return BigDouble._noNormalize(mantissa, exponent);
  } else if (mantissa == 0) {
    return BigDouble.zero;
  }
  int newExp = (dart_math.log(mantissa.abs()) / dart_math.ln10) as int;
  return BigDouble._noNormalize(
      newExp == numberExpMin
          ? mantissa * 10 / 1e-323
          : mantissa / lookupPowerOf10(newExp),
      exponent + newExp);
}
