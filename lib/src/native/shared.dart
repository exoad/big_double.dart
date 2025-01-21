/// For example: if two exponents are more than 17 apart,
/// consider adding them together pointless, just return the larger one
const int maxSignificantDigits = 17;

/// Highest value you can safely put here is `0x7FFFFFFFFFFFFFFF - MAX_SIGNIFICANT_DIGITS` where the int.max is represented as the
const int expLimit = intMaxValue - maxSignificantDigits;

/// The largest exponent that can appear in a Number, though not all mantissas are valid here.
const int numberExpMax = 308;

/// The smallest exponent that can appear in a Number, though not all mantissas are valid here.
const int numberExpMin = -324;

/// Tolerance which is used for Number conversion to compensate floating-point error.
const double roundTolerance = 1e-10;

/// Represents the smallest 64 bit integer on native platforms supported by Dart
const int intMinValue = -0x8000000000000000;

/// Represents the largest 64 bit integer on native platforms
const int intMaxValue = 0x7FFFFFFFFFFFFFFF;
