import "package:break_infinity/break_infinity.dart";
import "package:break_infinity/src/helpers.dart";
import "package:break_infinity/src/powers_of_10.dart";
import "package:test/test.dart";

void main() {
  print(
      "${identical(1.0, 1) ? "running WEB" : "running NATIVE"}\nInt_Max = $maxInt\nInt_Min = $minInt");
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
    test("BigDouble.parse('1e30').toDouble() == 1e30", () {
      expect(BigDouble.parse("1e30"), 1e30.big);
    });
    test("BigDouble.parse('1e30').toString() == 1.0e+30", () {
      expect(BigDouble.parse("1e30").toString(), isJavaScript ? "1e+30" : "1.0e+30");
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
      test("BigDouble(${-i}) < BigDouble($i) IS_TRUE", () {
        expect(-i.big < i.big, true);
      });
    }
  });
  group("BigDouble Arithmetic Tests", () {
    for (int i = 0; i < 300; i++) {
      test("BigDouble($i) * BigDouble($i) == ${i * i}", () {
        expect((i.big * i.big).toDouble(), i * i);
      });
    }
    for (int i = 100; i < 878; i++) {
      test("BigDouble($i) ^ 0 == 1", () {
        expect(pow(i.big, 0) == BigDouble.one, true);
      });
    }
    test("BigDouble(100) ^ 10 == 1e20", () {
      expect(pow(100.big, 10).toString(), 1e20.toString());
    });
    test("BigDouble(300) ^ 300 == 1.368e743", () {
      expect(pow(300.big, 300).toString(), "1.368914790585681e+743");
    });
  });
  group("BigDouble.floor", () {
    test("BigDouble.fromValue(0.9).floor == BigDouble.zero", () {
      expect(0.9.big.floor(), BigDouble.zero);
    });
    test("BigDouble.fromValue(1.1).floor == BigDouble.one", () {
      expect(1.1.big.floor(), BigDouble.one);
    });
    test("BigDouble.fromValue(1.5).floor == BigDouble.one", () {
      expect(1.5.big.floor(), BigDouble.one);
    });
    test("BigDouble.fromValue(2.5).floor == BigDouble(2)", () {
      expect(2.5.big.floor(), 2.big);
    });
  });
  group("BigDouble.ceil", () {
    test("BigDouble.fromValue(0.9).ceil == BigDouble.one", () {
      expect(0.9.big.ceil(), BigDouble.one);
    });
    test("BigDouble.fromValue(1.1).ceil == BigDouble(2)", () {
      expect(1.1.big.ceil(), 2.big);
    });

    test("BigDouble.fromValue(2.5).ceil == BigDouble(3)", () {
      expect(2.5.big.ceil(), 3.big);
    });
  });
  group("AdHoc Cases", () {
    for (int i = 800; i < 1000; i++) {
      test("IsNaN IS_FALSE [${i + 1}]", () {
        expect(BigDouble.random().isNaN, false);
      });
    }
    for (int i = 800; i < 1000; i++) {
      test("IsPositiveInfinity IS_FALSE [${i + 1}]", () {
        expect(BigDouble.random().isPositiveInfinity, false);
      });
    }
    for (int i = 800; i < 1000; i++) {
      test("IsNegativeInfinity IS_FALSE [${i + 1}]", () {
        expect(BigDouble.random().isNegativeInfinity, false);
      });
    }
   
  });
}
