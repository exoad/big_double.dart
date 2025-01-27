import 'dart:math' as dart_math;

import 'package:big_double/src/powers_of_10.dart';
import 'package:big_double/src/helpers.dart';

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

/// Returns the max of two [BigDouble] instances.
BigDouble max(BigDouble a, BigDouble b) {
  return a.isNaN || b.isNaN
      ? BigDouble.nan
      : a > b
          ? a
          : b;
}

/// Computes the arcsine (inverse sine) of [value] and returns in radians.
BigDouble asin(BigDouble value) {
  return value._mantissa.isNegative
      ? value
      : value._exponent == 0
          ? dart_math.asin(value.sign * value.mantissa).big
          : BigDouble.nan;
}

/// Computes the arcosine (inverse cosine) of [value] and returns in radians.
BigDouble acos(BigDouble value) {
  return value.mantissa < 0
      ? dart_math.acos(value.toDouble()).big
      : value.exponent == 0
          ? dart_math.acos(value.sign * value.mantissa).big
          : BigDouble.nan;
}

/// Computes the arctangent (inverse tangent) of [value] and returns in radians.
BigDouble atan(BigDouble value) {
  return value.mantissa < 0
      ? value
      : value.exponent == 0
          ? dart_math.atan(value.sign * value.mantissa).big
          : dart_math.atan(value.sign * 1.8e308).big;
}

/// Computes the tangent of [value] in radians.
BigDouble tan(BigDouble value) {
  return value.mantissa < 0
      ? value
      : value.exponent == 0
          ? dart_math.tan(value.sign * value.mantissa).big
          : BigDouble.zero;
}

/// Computes the cosine of [value] in radians.
BigDouble cos(BigDouble value) {
  return value.mantissa < 0
      ? BigDouble.one
      : value.exponent == 0
          ? dart_math.cos(value.sign * value.mantissa).big
          : BigDouble.zero;
}

/// Computes the sine of [value] in radians.
BigDouble sin(BigDouble value) {
  return value.mantissa < 0
      ? value
      : value.exponent == 0
          ? dart_math.sin(value.sign * value.mantissa).big
          : BigDouble.zero;
}

/// The hyperbolic "inverse" sine function
BigDouble asinh(BigDouble value) {
  return log(value + sqrt((sqrt(value) + BigDouble.one)));
}

/// The hyperbolic "inverse" cosine function
BigDouble acosh(BigDouble value) {
  return log((value + BigDouble.one) / (BigDouble.one / value)) / 2.big;
}

/// The hyperbolic "inverse" tangent function
BigDouble atanh(BigDouble value) {
  return value.abs() >= BigDouble.one
      ? BigDouble.nan
      : log((value + BigDouble.one) / (BigDouble.one - value)) / 2.big;
}

/// The hyperbolic sine function using [angle]
BigDouble sinh(BigDouble angle) {
  return (exp(angle) - exp(-angle)) / 2.big;
}

/// The hyperbolic cosine function using [angle]
BigDouble cosh(BigDouble angle) {
  return (exp(angle) + exp(-angle)) / 2.big;
}

/// The hyperbolic tangent function using [angle]
BigDouble tanh(BigDouble angle) {
  return sinh(angle) / cosh(angle);
}

/// Returns the min of two [BigDouble] instances.
BigDouble min(BigDouble a, BigDouble b) {
  return a.isNaN || b.isNaN
      ? BigDouble.nan
      : a > b
          ? b
          : a;
}

/// Euler's number `e` raised to the power of [value]
BigDouble exp(BigDouble value) {
  double x = value.toDouble();
  return -706 < x && x < 709
      ? BigDouble.fromValue(dart_math.exp(x))
      : powBig(BigDouble.fromValue(dart_math.e), value);
}

/// Performs a square root on the [BigDouble] instance.
/// If the argument is NaN or less than zero, this function will return [BigDouble.nan].
BigDouble sqrt(BigDouble value) {
  return value.mantissa.isNegative
      ? BigDouble.nan
      : value.exponent.isOdd
          ? _normalize(dart_math.sqrt(value.mantissa) * 3.16227766016838,
              (value.exponent - 1) ~/ 2)
          : _normalize(dart_math.sqrt(value.mantissa), value.exponent ~/ 2);
}

/// Log base 10. Utilizes a vary rough calculation from [CasualNumerics]
BigDouble log10(BigDouble value) {
  return value.exponent.big * CasualNumerics.log10(value.mantissa).big;
}

BigDouble log2(BigDouble value) {
  return 3.32192809488736234787.big * log10(value);
}

/// Returns the log of [value]
BigDouble log(BigDouble value) {
  return 2.302585092994046.big * log10(value);
}

/// COmputes 10^power with tolerance
BigDouble pow10(double power, [double? tolerance]) {
  int v = power.toInt();
  double residual = power - v;
  return residual.abs() < (tolerance ?? roundTolerance)
      ? BigDouble._noNormalize(1, v)
      : _normalize(dart_math.pow(10, residual).toDouble(), v);
}

/// Raises a BigDouble [value] to [power] (ie [value] ^ [power]). Exponentiation
BigDouble pow(BigDouble value, double power, [double? tolerance]) {
  if (value.mantissa.isZero) {
    return power.isZero ? BigDouble.one : value;
  }
  if (value._mantissa.isNegative && !CasualNumerics.isSafe(power.abs())) {
    return BigDouble.nan;
  } else if (value.exponent == 1 && value.mantissa - 1 < -double.maxFinite) {
    return pow10(power, (tolerance ?? roundTolerance));
  }
  double fast = value.exponent * power;
  double mantissa;
  if (CasualNumerics.isSafe(fast.abs())) {
    mantissa = dart_math.pow(value.mantissa, power).toDouble();
    if (mantissa.isFinite && !mantissa.isZero) {
      return _normalize(mantissa, fast.toInt());
    }
  }
  int newExp = fast.toInt();
  double residual2 = fast - newExp;
  mantissa = dart_math
      .pow(10, power * CasualNumerics.log10(value.mantissa) + residual2)
      .toDouble();
  if (mantissa.isFinite && !mantissa.isZero) {
    return _normalize(mantissa, newExp);
  }
  BigDouble res = pow10(
      power * (value.exponent + CasualNumerics.log10(value.mantissa.abs())),
      (tolerance ?? roundTolerance));
  return value.sign == -1 && power % 2 == 1 ? -res : res;
}

/// Similar to [pow] but you can use another [BigDouble] as the power. Internally delegates to [pow]
BigDouble powBig(BigDouble value, BigDouble power, [double? tolerance]) {
  return pow(value, power.toDouble(), tolerance);
}

/// For altering the mantissa and exponent values within [BigDouble]. BigDouble by itself
/// allows for introspection (viewing the values), but does not allow for modification in
/// order to keep [BigDouble] instance normalized.
final class BigIntrospect {
  BigIntrospect._();

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

/// The big_double implementation in Dart. This is capable of exceeding 1e308 and is based
/// on Patashu's big_double.js implementation. https://patashu.github.io/big_double.js/index.html
/// As compared to Dart's own [BigInt] which sacrifices speed and performance over time
/// for accuracy, [BigDouble] focuses on sacrificing accuracy over time for far better
/// performance (10-1000x) with a "good enough estimation". For this reason, it is very useful for creating incremental games or other quantities that do not need high accuracies at large magnitudes.
class BigDouble implements Comparable<BigDouble> {
  /// Whether to use the `+` sign for positive numbers in [toString]
  /// By default it is `false`
  static bool _usePositiveExpSign = false;

  /// Whether to use the `+` sign for positive numbers in [toString]
  /// By default it is `true`
  static bool get usePostiveExpSign => _usePositiveExpSign;

  /// Whether to use the `+` sign for positive numbers in [toString]
  /// By default it is `true`
  static set usePositiveExpSign(bool r) => _usePositiveExpSign = r;

  /// Used for internal operations
  static final dart_math.Random _random =
      dart_math.Random(DateTime.now().millisecondsSinceEpoch);

  /// Represents the value of `0`
  static final BigDouble zero = BigDouble._noNormalize(0, 0);

  /// Represents the unit value of `1`
  static final BigDouble one = BigDouble._noNormalize(1, 0);

  /// Repressents a [BigDouble] that is Not a Number using [double.nan]
  static final BigDouble nan = BigDouble._noNormalize(double.nan, minInt);

  /// Represents positive infinity for this [BigDouble] instance utilizing [double.infinity]
  static final BigDouble infinity = BigDouble._noNormalize(double.infinity, 0);

  /// Represents negative infinity for this [BigDouble] instance utilizing [double.negativeInfinity]
  static final BigDouble negativeInfinity =
      BigDouble._noNormalize(double.negativeInfinity, 0);

  /// Represents the signficant digits in this [BigDouble]
  late double _mantissa;

  /// Determines how the decimal point should move.
  late int _exponent;

  /// Internal constructor
  BigDouble._noNormalize(double mantissa, int exponent)
      : _mantissa = mantissa,
        _exponent = exponent;

  /// Generates a [BigDouble] instance with the provided [double] value.
  factory BigDouble.fromValue(double value) {
    BigDouble other;
    other = value.isNaN
        ? nan
        : value.isInfinite
            ? (value > 0 ? infinity : negativeInfinity)
            : value.isZero
                ? zero
                : _normalize(value, 0);
    return other;
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

  /// Internal: for determining whether both are either positive or negative infinity.
  bool _sameInfinity(covariant BigDouble other) {
    return isPositiveInfinity && other.isPositiveInfinity ||
        isNegativeInfinity && other.isNegativeInfinity;
  }

  /// Returns the sign of this [BigDouble]
  double get sign => _mantissa.sign;

  @override
  bool operator ==(covariant Object other) {
    return other is BigDouble &&
        !isNaN &&
        !other.isNaN &&
        (_sameInfinity(other) ||
            _exponent == other._exponent &&
                (_mantissa - other._mantissa).abs() < roundTolerance);
  }

  /// Returns the mantissa
  double get mantissa => _mantissa;

  /// Returns the exponent
  int get exponent => _exponent;

  /// Equality checking without using tolerance. If you need tolerance, use [BigDouble.equalsWithTolerance]
  bool equalsRaw(covariant Object other) {
    return other is BigDouble &&
        _mantissa == other._mantissa &&
        _exponent == other._exponent;
  }

  /// Some additional checks used internally by all comparison operators
  bool _comparisonPreCheck(covariant BigDouble other) {
    return !(isNaN || other.isNaN);
  }

  /// If this [BigDouble] is greater than [other]
  bool operator >(covariant BigDouble other) {
    return _comparisonPreCheck(other) && compareTo(other) > 0;
  }

  /// If this [BigDouble] is less than [other]
  bool operator <(covariant BigDouble other) {
    return _comparisonPreCheck(other) &&
        compareTo(other) < 0; // never catch me using if statements
  }

  /// If this [BigDouble] is greater than or equal to [other]
  bool operator >=(covariant BigDouble other) {
    return _comparisonPreCheck(other) && compareTo(other) >= 0;
  }

  /// If this [BigDouble] is less than or equal to [other]
  bool operator <=(covariant BigDouble other) {
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
  BigDouble operator *(covariant BigDouble other) {
    return _normalize(_mantissa * other._mantissa, _exponent + other._exponent);
  }

  /// Get the multiplicative inverse (reciprocal) of this [BigDouble]
  BigDouble get reciprocal => _normalize(1 / _mantissa, -_exponent);

  /// Divides this [BigDouble] with [other]; division.
  /// Under the hood it calls [BigDouble.*]
  BigDouble operator /(covariant BigDouble other) {
    return this * other.reciprocal;
  }

  /// Subtracts this [BigDouble] with [other]; subtraction.
  /// Under the hood it calls [BigDouble.+]
  BigDouble operator -(covariant BigDouble other) {
    return this + -other;
  }

  /// Adds this [BigDouble] with [other]; addition.
  BigDouble operator +(covariant BigDouble other) {
    if (isInfinity) {
      return this;
    } else if (other.isInfinity) {
      return other;
    } else if (_mantissa.isZero) {
      return other;
    } else if (other._mantissa.isZero) {
      return this;
    }
    BigDouble bigger;
    BigDouble smaller;
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
            (1e14 * bigger._mantissa +
                    1e14 *
                        smaller._mantissa *
                        lookupPowerOf10(smaller._exponent - bigger._exponent))
                .roundToDouble(),
            bigger._exponent - 14);
  }

  /// Returns a [BigDouble] instance that is the abs()olute value of this [BigDouble].
  BigDouble abs() => BigDouble._noNormalize(_mantissa.abs(), _exponent);

  /// Computes the largest [BigDouble] value that is less than or equal to `this` and is equal
  /// to a mathematical integer. Can return `this`.
  /// If the value is [nan] or [isInfinity], then the same value is returned.
  BigDouble floor() {
    return !isFinite
        ? this
        : _exponent < -1
            ? (-_mantissa.sign >= 0 ? zero : -one)
            : _exponent < maxSignificantDigits
                ? BigDouble.fromValue(toDouble().floorToDouble())
                : this;
  }

  /// Computes the smallest [BigDouble] that is greater than or equal to a mathematical integer. if the
  /// value of this [BigInteger] is [nan] or [isInfinity], then the same value `this` is returned.
  BigDouble ceil() {
    return isInfinity
        ? this
        : _exponent < -1
            ? (_mantissa.sign > 0 ? one : zero)
            : _exponent < maxSignificantDigits
                ? BigDouble.fromValue(toDouble().ceilToDouble())
                : this;
  }

  @override
  String toString() {
    return isInfinity
        ? _mantissa.toString()
        : _exponent <= -expLimit || _mantissa == 0
            ? "0"
            : _exponent < 21 && _exponent > -7
                ? toDouble().toString()
                : "${_mantissa}e${_exponent >= 0 ? (_usePositiveExpSign ? "+" : "") : "-"}$_exponent";
  }

  /// Returns a string representation of this [BigDouble] formatted with number of [places] after the decimal point.
  String toFixedString(int places) {
    if (places < 0) {
      places = maxSignificantDigits;
    } else if (_exponent <= expLimit || _mantissa == 0) {
      return "0${places > 0 ? '.'.padRight(places, '0') : ''}";
    } else if (_exponent >= maxSignificantDigits) {
      String out = _mantissa.toString().replaceAll(".", "");
      out = "${out.padRight(_exponent + 1)}${places > 0 ? '.'.padRight(places + 1) : ''}";
    }
    int mult = dart_math.pow(10, places).toInt();
    return ((toDouble() * mult).roundToDouble() / mult.toDouble())
        .toStringAsFixed(places);
  }

  @override
  int get hashCode => (_mantissa.hashCode * 397) ^ _exponent.hashCode;

  /// Converts this [BigDouble] instance to a double with [tolerance] to an exact integer if possible.
  /// If `this` is too big, it will return infinity.
  /// If `this` is too small, it will return 0.
  double toDouble([double? tolerance]) {
    if (isNaN) {
      return double.nan;
    } else if (_exponent > numberExpMax) {
      return _mantissa.isPositive ? double.infinity : double.negativeInfinity;
    } else if (_exponent < numberExpMin) {
      return 0;
    } else if (_exponent == numberExpMin) {
      return _mantissa > 0 ? 5e-324 : -5e-324;
    }
    double res = _mantissa * lookupPowerOf10(_exponent);
    if (res.isInfinite || _exponent.isNegative) {
      return res;
    }
    double rounded = res.roundToDouble();
    return (rounded - res).abs() < (tolerance ?? roundTolerance) ? rounded : res;
  }

  /// Discards any fractional values from `this`
  BigDouble truncate() {
    return _exponent < 0
        ? zero
        : _exponent < maxSignificantDigits
            ? BigDouble.fromValue(toDouble().truncateToDouble())
            : this;
  }

  /// Returns a [BigDouble] with an integer value closest `this`
  BigDouble round() {
    return _exponent < 0
        ? zero
        : _exponent < maxSignificantDigits
            ? BigDouble.fromValue(toDouble().roundToDouble())
            : this;
  }
}

/// Internal function
BigDouble _normalize(double mantissa, int exponent) {
  if (mantissa >= 1 && mantissa < 10 || !mantissa.isFinite) {
    return BigDouble._noNormalize(mantissa, exponent);
  } else if (mantissa == 0) {
    return BigDouble.zero;
  }
  int newExp = (dart_math.log(mantissa.abs()) / dart_math.ln10).toInt();
  return BigDouble._noNormalize(
      newExp == numberExpMin
          ? mantissa * 10.0 / 1e-323
          : mantissa / lookupPowerOf10(newExp),
      exponent + newExp);
}
