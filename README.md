# big_double
![Tests](https://img.shields.io/github/actions/workflow/status/exoad/big_double/test.yml?style=flat-square&label=tests%20status)

`BigInt` and `double` replacement that can hold up to 10^10^308 for Dart. The goal of this library is to focus on speed and memory footprint rather than accuracy especially when the value is very very large leading to traditional approaches like `BigInt` performing horribly. 

<a href="https://www.buymeacoffee.com/exoad" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="width:170px" ></a>

## Installation
Install the library

```bash
dart pub add break_infinity
```

or

```bash
flutter pub add break_infinity
```

Import the library into your project

```dart
import "package:break_infinity/break_infinity.dart";
```

## Using a BIG double

There are multiple ways to acquire a `BigDouble`. A `BigDouble` is the class that contains the value and can be constructed via multiple
methods:

### Initialization

#### 💡 Numerical Suffix

***Recommended***

All `double` and `int` types have an extension `.big` that can be used to easily turn that value into a `BigDouble` instance:

```dart
print(1.big + 2.big);
```

Furthermore, there are also extensions on 2 tuple types: `(int, int)` and `(double, int)` which are represented by default for the `BigDouble`
internal structure. The first parameter is always the **mantissa** value, while the second parameter is the **exponent** value.

```dart
print((12.0, 3).big + (4, 10).big);
```

#### 💡 String Parsing

***Recommended***

`BigDouble.parse(String)` and `BigDouble.tryParse(String)` are useful when the value is just now too large to represent with numerical literals. It is also paired with the `toString()` method for easy back-and-forth serializing and deserializing. The format must follow the format of `{mantissa}e{exponent}`

> Additionally, the `tryParse` variant will return `BigDouble.nan` if parsing failed, while `parse` throws a `FormatException`.

```dart
print(BigDouble.parse("1e30"));
```

#### Direct Initialization with Constructor

If you have your method of storing the original value, then you can use this method to get the value back. The default constructor `BigDouble(double, int)` provides you with a way to supply the mantissa and exponent respectively.

```dart
print(BigDouble(1, 308)); // would be equivalent to saying 1e308
```

### Arithmetic

All basic arithmetic operations are supported such as `+`, `-`, `*`, `/`, and `-` (negation) and all of which are handled through operator overloading:

```dart
print(1.big + 3.big); // 4.big
```

### Accessibility & Safety

Within every `BigDouble`, its value is represented by 2 values previously mentioned:
1. **Mantissa** - Contains the significant digits in the number. (*Significand*)
2. **Exponent** - Represents the number of decimal places that need to be moved.

You can **view** these values with just a `BigDouble`. **However, you are not allowed to directly modify the values.** This is because directly modifying these values will cause the `BigDouble` to become not normalized leading to certain operations potentially producing incorrect results.

> [!CAUTION]
> If you want to modify these values, you must use the `BigIntrospect` class, but keep in mind, that you must manually normalize the `BigDouble` instance after.

```dart
BigDouble a = 3.big;
print(a.mantissa); // OK
a.exponent = 100;  // ERROR
BigIntrospect.changeExponent(a, 100); // OK
```

### Math Library

There are additional helper functions for you to use that help you with additional computations. For example, the `pow(BigDouble, double)` function which raises a `BigDouble` to a certain power. All of the function styles have been adapted from Dart's format such as how a double has `.abs()` which will make utilizing
a `BigDouble` just like using vanilla Dart!

🥳 _**Voilà!**_ For more information on additional usage, read the documentation [here]().

## Compatibility & Limitations

This library primarily operates to support both `native` and `web` platforms. These platforms are as follows

> * **Dart Native**: For programs targeting devices (mobile, desktop, server, and more), Dart Native includes both a Dart VM with JIT (just-in-time) compilation and an AOT (ahead-of-time) compiler for producing machine code.
> * **Dart Web**: For programs targeting the web, Dart Web includes both a development time compiler (dartdevc) and a production time compiler (dart2js).
>
> From [dart-lang/sdk](https://github.com/dart-lang/sdk)

> [!WARNING]
> However, the internal workings of this library depend on `int` and `double`, but the constraints of these [types vary between `web` and `native`](https://dart.dev/language/built-in-types#numbers) which will need to be taken into consideration when using this package, but for the most part, a lot of the constraints have been solved
> within this library itself.
 
## Acknowledgements

### [Patashu/break_infinity.js](https://github.com/Patashu/break_infinity.js)

### [AD417/BreakInfinity.java](https://github.com/AD417/BreakInfinity.java)

### [Patashu/break_eternity.js](https://github.com/Patashu/break_eternity.js)

### Contributors

<a href="https://github.com/exoad/break_infinity.dart/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=exoad/break_infinity.dart" />
</a>
