import 'package:break_infinity/break_infinity.dart';

void main() {
  BigDouble sum = (1e30).big + (1e30).big;
  print(sum.toDouble());
  print(sum);
  print("Mantissa = ${sum.mantissa}\nExponent = ${sum.exponent}");
  BigDouble product = BigDouble.fromValue(996) * BigDouble.fromValue(996);
  print(product.toDouble().round());
  print(asin(0.3.big));
}
