/// For example: if two exponents are more than 17 apart,
/// consider adding them together pointless, just return the larger one
const double maxSignificantDigits = 17;

/// Highest value you can safely put here is `1.7976931348623157e+308 - MAX_SIGNIFICANT_DIGITS` which int.max is
/// calculated with [double.maxFinite]
const double expLimit = double.maxFinite - maxSignificantDigits;

/// The largest exponent that can appear in a Number, though not all mantissas are valid here.
const double numberExpMax = 308;

/// The smallest exponent that can appear in a Number, though not all mantissas are valid here.
const double numberExpMin = -324;

/// Tolerance which is used for Number conversion to compensate floating-point error.
const double roundTolerance = 1e-10;

/// Represents the smallest integer on web platforms supported by JavaScript
const double intMinValue = -double.maxFinite;

/// Represents the largest integer on native platforms
const double intMaxValue = double.maxFinite;
