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
    test("BigDouble.parse('1e30').toDouble() == 1e30", () {
      expect(BigDouble.parse("1e30").toDouble() == 1e30, true);
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
      expect(BigDouble(123, 5).toDouble(), BigDouble(1.23, 7).toDouble());
    });
    for (int i = 1; i < 1000; i++) {
      test("BigDouble(${-i}) < BigDouble($i) == true", () {
        expect(-i.big < i.big, true);
      });
    }
  });
  group("BigDouble Arithmetic Tests", () {
    for (int i = 0; i < 1000; i++) {
      test("BigDouble($i)* BigDouble($i) == ${i * i}", () {
        expect(i.big * i.big, (i * i).big);
      });
    }
  });
  group("AdHoc Cases", () {
    for (int i = 0; i < 1000; i++) {
      test("IsNaN != true [${i + 1}]", () {
        expect(BigDouble.random().isNaN, false);
      });
    }
    for (int i = 0; i < 1000; i++) {
      test("IsPositiveInfinity != true [${i + 1}]", () {
        expect(BigDouble.random().isPositiveInfinity, false);
      });
    }
    for (int i = 0; i < 1000; i++) {
      test("IsNegativeInfinity != true [${i + 1}]", () {
        expect(BigDouble.random().isNegativeInfinity, false);
      });
    }
  });
}
