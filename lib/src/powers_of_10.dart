import 'package:break_infinity/src/helpers.dart';

List<double> __generate() {
  List<double> res = List<double>.filled(numberExpMax - numberExpMin, 0);
  for (int i = numberExpMin + 1; i <= numberExpMax; i++) {
    res[i - numberExpMin - 1] = double.parse("1e$i");
  }
  return res;
}

const int indexOf0InPowersOf10 = 323;
List<double> _powersOf10 = __generate();

double lookupPowerOf10(int power) => _powersOf10[power + indexOf0InPowersOf10];
