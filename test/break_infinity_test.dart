import "package:break_infinity/break_infinity.dart";
import "package:break_infinity/src/powers_of_10.dart";
import "package:test/test.dart";

void main() {
  // Generic helper tests begin here
  group("Powers of 10 Tests", () {
    test("lookupPowerOfTen(308) == 1e308", () {
      expect(lookupPowerOf10(308), 1e308);
    });
    test("lookoupPowerOfTen(-323) == 1e-323", () {
      expect(lookupPowerOf10(-323), 1e-323);
    });
    test("lookoupPowerOfTen(0) == 1", () {
      expect(lookupPowerOf10(0), 1);
    });
  });
  // Big Double tests begin here
  group("BigDouble Representation Tests", () {
    test("BigDouble.fromValue(10).toDouble() == 10 as double", () {
      expect(BigDouble.fromValue(10).toDouble(), 10);
    });
    test("BigDouble.fromValue(1e30).toDouble() == 1e30 as double", () {
      expect(BigDouble.fromValue(1e30).toDouble(), 1e30);
    });
  });
  group("BigDouble Comparison Tests", () {
    test("BigDouble.fromValue(34) != BigDouble.fromValue(10)", () {
      expect(BigDouble.fromValue(34) == BigDouble.fromValue(10), false);
    });
    test("BigDouble.fromValue(4) < BigDouble.fromValue(5)", () {
      expect(4.big < 5.big, true);
    });
    test("BigDouble(123, 5) == BigDouble(1.23, 7)", () {
      expect(BigDouble(123, 5) == BigDouble(1.23, 7), true);
    });
  });
  group("BigDouble Arithmetic Tests", () {
    test("BigDouble(1) + BigDouble(2) all as double == 3 as double", () {
      expect((1.big + 2.big).toDouble(), 3.0);
    });
  });
}
