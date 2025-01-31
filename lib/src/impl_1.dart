import 'dart:math' as dart_math;

import 'package:big_double/src/extensions.dart';
import 'package:big_double/src/powers_of_10.dart';
import 'package:big_double/src/helpers.dart';

/// Returns the max of two [BigDouble] instances.
BigDouble max(BigDouble a, BigDouble b) {
  return a.isNaN || b.isNaN
      ? BigDouble.nan
      : a > b
          ? a
          : b;
}

/// The hyperbolic "inverse" sine function
double asinh(BigDouble value) {
  return log(value + sqrt((sqrt(value) + BigDouble.one)));
}

/// The hyperbolic "inverse" cosine function
double acosh(BigDouble value) {
  return log((value + BigDouble.one) / (BigDouble.one / value)) / 2;
}

/// The hyperbolic "inverse" tangent function
double atanh(BigDouble value) {
  return value.abs() >= BigDouble.one
      ? double.nan
      : log((value + BigDouble.one) / (BigDouble.one - value)) / 2;
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
      : pow(BigDouble.fromValue(dart_math.e), value);
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

/// Performs a cube root on [value].
BigDouble cbrt(BigDouble value) {
  int sign = 1;
  double m = value.mantissa;
  if (m < 0) {
    sign = -1;
    m = -m;
  }
  num m2 = sign * dart_math.pow(m, 1 / 3);
  double mod = value.exponent % 3;
  return BigDouble(
      mod == 1 || mod == -2
          ? m2 * 2.154434690031883
          : mod != 0
              ? m2 * 4.641588833612778
              : m2,
      (value.exponent / 3).floor());
}

/// Log base 10. Utilizes a very rough calculation from [CasualNumerics]
double log10(BigDouble value) {
  return value.exponent + CasualNumerics.log10(value.mantissa);
}

/// Log base 10 magnitude. Utilizes a very rough calculation from [CasualNumerics]
double absLog10(BigDouble value) {
  return value.exponent + CasualNumerics.log10(value.mantissa.abs());
}

/// Log base 10 clamped to 0.
double pLog10(BigDouble value) {
  return value.mantissa <= 0 || value.exponent < 0 ? 0 : log10(value);
}

/// Log base 2
double log2(BigDouble value) {
  return 3.32192809488736234787 * log10(value);
}

/// Returns the log of [value] with an optional [base]
double log(BigDouble value, [double? base]) {
  return base == null
      ? 2.302585092994046 * log10(value)
      : (dart_math.ln10 / dart_math.log(base)) * log10(value);
}

/// Natural Logarithm
double ln(BigDouble value) {
  return 2.302585092994045 * log10(value);
}

/// Computes 10^power with tolerance
BigDouble pow10(double power, [double? tolerance]) {
  return CasualNumerics.isInt(power)
      ? BigDouble._noNormalize(1, power.truncate())
      : _normalize(dart_math.pow(10, power % 1), power.truncate());
}

/// Raises a BigDouble [value] to [power] (ie [value] ^ [t]). Exponentiation
BigDouble pow(BigDouble value, dynamic t, [double? tolerance]) {
  if (!(t is BigDouble) && !(t is num)) {
    throw "pow() accepts either a power of [BigDouble] or [num]!";
  }
  double power = t is BigDouble
      ? t.toDouble()
      : t is int
          ? t.toDouble()
          : t;
  int temp = (value.exponent * power).toInt();
  late double newMantissa;
  if (CasualNumerics.isSafe(temp)) {
    newMantissa = dart_math.pow(value.mantissa, power).toDouble();
    if (newMantissa.isFinite && newMantissa != 0) {
      return BigDouble(newMantissa, temp);
    }
  }
  int newExp = temp.toInt();
  int residue = temp - newExp;
  newMantissa = dart_math
      .pow(10, power * CasualNumerics.log10(value.mantissa) + residue)
      .toDouble();
  if (newMantissa.isFinite && newMantissa != 0) {
    return BigDouble(newMantissa, newExp);
  }
  BigDouble res = pow10(power * absLog10(value));
  if (value.sign == -1) {
    if ((temp % 2).abs() == 1) {
      return -res;
    } else if ((temp % 2).abs() == 0) {
      return res;
    }
    return BigDouble.nan;
  }
  return res;
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
  late num _mantissa;

  /// Determines how the decimal point should move.
  late int _exponent;

  /// Internal constructor
  BigDouble._noNormalize(num mantissa, int exponent)
      : _mantissa = mantissa,
        _exponent = exponent;

  /// Generates a [BigDouble] instance with the provided [double] value.
  factory BigDouble.fromValue(num value) {
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
  BigDouble(num mantissa, int exponent) {
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
  num get sign => _mantissa.sign;

  @override
  bool operator ==(covariant Object other) {
    return other is BigDouble &&
        !isNaN &&
        !other.isNaN &&
        (_sameInfinity(other) ||
            _exponent == other._exponent &&
                (_mantissa - other._mantissa).abs() < roundTolerance);
  }

  /// Named [Object.==]
  bool equals(covariant Object other) {
    return this == other;
  }

  /// An alternative to [BigDouble.==] but instead there is a [tolerance] for checking equality.
  bool almostEquals(covariant BigDouble other, [BigDouble? tolerance]) {
    tolerance ??= roundToleranceForm;
    return (this - other).abs() <= max(this.abs(), other.abs()) * tolerance;
  }

  /// Returns the mantissa
  double get mantissa => _mantissa.toDouble();

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

  /// Named [BigDouble.<]
  bool lessThan(covariant BigDouble other) {
    return this < other;
  }

  /// Named [BigDouble.<=]
  bool lessThanOrEqualTo(covariant BigDouble other) {
    return this <= other;
  }

  /// Named [BigDouble.>]
  bool greaterThan(covariant BigDouble other) {
    return this > other;
  }

  /// Named [BigDouble.>=]
  bool greaterThanOrEqualTo(covariant BigDouble other) {
    return this >= other;
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

  /// An oversight version of exponentiation of [this] ^ [other] by overloading the bitwise XOR operator.
  BigDouble operator ^(covariant BigDouble other) {
    return pow(this, other);
  }

  /// Subtracts this [BigDouble] with [other]; subtraction.
  /// Under the hood it calls [BigDouble.+]
  BigDouble operator -(covariant BigDouble other) {
    return this + -other;
  }

  /// Named [BigDouble.+]
  BigDouble add(num other) {
    return this + other.big;
  }

  /// Named [BigDouble.-]
  BigDouble subtract(num other) {
    return this - other.big;
  }

  /// Named [BigDouble.*]
  BigDouble multiply(num other) {
    return this * other.big;
  }

  /// Named [BigDouble.-] negation
  BigDouble negate() {
    return -this;
  }

  /// Named [BigDouble./]
  BigDouble divide(num other) {
    return this / other.big;
  }

  /// Determines if this is within[minimum] and [maximum]. If it is below, return [minimum]. If it is above, return [maximum]
  BigDouble clamp(BigDouble minimum, BigDouble maximum) {
    return min(max(minimum, this), maximum);
  }

  /// Adds this [BigDouble] with [other]; addition.
  BigDouble operator +(covariant BigDouble other) {
    if (isInfinity) {
      throw "Infinity";
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

  /// Exponential format with [places] as the number of decimal places for the mantissa.
  String toExponentialString(int places) {
    if (!places.isFinite) {
      places = maxSignificantDigits;
    }
    if (!isFinite) {
      return mantissa.toString();
    } else if (exponent <= -expLimit || mantissa == 0) {
      return "0${trailZeroes(places)}e${_usePositiveExpSign ? '+' : ''}0";
    } else if (exponent > numberExpMin && exponent < numberExpMax) {
      return toDouble().toStringAsExponential(places);
    }
    int len = places + 1;
    int digits = dart_math.max(1, CasualNumerics.log10(mantissa.abs()).ceil());
    num rded = (mantissa * dart_math.pow(10, len - digits)).round() *
        dart_math.pow(10, digits - len);
    return "${rded.toStringAsFixed(dart_math.max(len - digits, 0))}e${exponent >= 0 && _usePositiveExpSign ? '+' : ''}$exponent";
  }

  /// Returns a string representation of this [BigDouble] formatted with number of [places] after the decimal point.
  String toFixedString(int places) {
    if (!isFinite) {
      return mantissa.toString();
    }
    if (exponent <= -expLimit || mantissa == 0) {
      return "0${trailZeroes(places)}";
    }
    if (exponent >= maxSignificantDigits) {
      String m = mantissa.toString().replaceAll(".", "");
      return "$m${ZeroStringInterner.poke(exponent - m.length + 1)}${trailZeroes(places)}";
    }
    return toDouble().toStringAsFixed(places);
  }

  /// Returns a string with a specific precision [places]
  String toPrecisionString(int places) {
    return exponent <= -7
        ? toExponentialString(places - 1)
        : places > exponent
            ? toFixedString(places - exponent - 1)
            : toExponentialString(places - 1);
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
BigDouble _normalize(num mantissa, int exponent) {
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
