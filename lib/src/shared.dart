import 'package:break_infinity/src/helpers.dart';

/// For example: if two exponents are more than 17 apart,
/// consider adding them together pointless, just return the larger one
const int maxSignificantDigits = 17;

/// Highest value you can safely put here is `0x7FFFFFFFFFFFFFFF - MAX_SIGNIFICANT_DIGITS` where the int.max is represented as the
final int expLimit = maxInt - maxSignificantDigits;

/// The largest exponent that can appear in a Number, though not all mantissas are valid here.
const int numberExpMax = 308;

/// The smallest exponent that can appear in a Number, though not all mantissas are valid here.
const int numberExpMin = -324;

/// Tolerance which is used for Number conversion to compensate floating-point error.
final double roundTolerance = 1e-10;

// The following is adapted from https://github.com/dart-lang/sdk/issues/41717#issuecomment-622312466

/// Represents the largest integer on platforms supported by Dart
final int maxInt = isJavaScript ? double.infinity as int : ~minInt;

/// Represents the smallest integer on platforms supported by Dart
final int minInt = isJavaScript ? -double.infinity as int : (-1 << 63);
