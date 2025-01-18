import "package:break_infinity/src/powers_of_10.dart";
import "package:test/test.dart";

void main() {
  group("Powers of 10", () {
    test("lookupPowerOfTen(308)", () {
      expect(lookupPowerOf10(308), 1e308);
    });
    test("lookoupPowerOfTen(-323)", () {
      expect(lookupPowerOf10(-323), 1e-323);
    });
    test("lookoupPowerOfTen(0)", () {
      expect(lookupPowerOf10(0), 1);
    });
  });
}
