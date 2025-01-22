# break_infinity.dart
![Tests](https://img.shields.io/github/actions/workflow/status/exoad/break_infinity.dart/test.yml?style=flat-square&label=tests%20status)

`BigInt` and `double` replacement that can hold up to 1e9e15 for Dart. The goal of this library is to focus on speed and memory footprint rather than accuracy especially when the value is very very large leading to traditional approaches like `BigInt` performing horribly. 

Dart port of [Patashu/break_infinity.js](https://github.com/Patashu/break_infinity.js)

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

## Usage

There are multiple ways to acquire a `BigDouble`. A `BigDouble` is the class that contains the value and can be constructed via multiple
methods:

### Initialization

#### 💡 Numerical Suffix

***Recommended***

All `double` and `int` types have an extension `.big` that can be used to easily turn that value into a `BigDouble` instance:

```dart
print(1.big + 2.big);
```

Furthermore, there are also extension on 2 tuple types: `(int, int)` and `(double, int)` of which are represented by default for the `BigDouble`
internal structure. The first parameter is always the **mantissa** value, while the second parameter is the **exponent** value.

```dart
print((12.0, 3).big + (4, 10).big);
```

#### 💡 String Parsing

***Recommended***

`BigDouble.parse(String)` and `BigDouble.tryParse(String)` are useful for when the value is just now too large to represent with numerical literals. It is also paired with `toString()` method for easy back and forth serializing and deserializing. The format must follow the format of `{mantissa}e{exponent}`

> Additionally, the `tryParse` variant will return `BigDouble.nan` if parsing failed, while `parse` throws a `FormatException`.

```dart
print(BigDouble.parse("1e30"));
```

#### Direct Initialization with Constructor

If you have your own method of storing the original value, then you can use this method to get the value back. The default constructor `BigDouble(double, int)` provides you with a way to supply the mantissa and exponent respectively.

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
2. **Exponent** - Represents the number of decimal places need to be moved.

You are able to **view** these values with just a `BigDouble`. **However, you are not allowed to directly modify the values.** This is due to the fact that directly modifying these values will cause the `BigDouble` to become not normalized leading to certain operations potentially producing incorrect results.

> [!CAUTION]
> If you want to modify these values, you must use the `BigIntrospect` class, but keep in mind, you must manually normalize the `BigDouble` instance after.

```dart
BigDouble a = 3.big;
print(a.mantissa); // GOOD
a.exponent = 100;  // ERROR
BigIntrospect.changeExponent(a, 100); // GOOD
```

### Math Library

There are additional helper functions for you to use that help you with additional computations. For example, the `pow(BigDouble, double)` function which raises a `BigDouble` to a certain power.

🥳 _**Voilà!**_ For more information on additional usage, read the documentation [here]().

## Compatibility & Limitations

This library primarily operates to support both `native` and `web` platforms. These platforms are as follows

> * **Dart Native**: For programs targeting devices (mobile, desktop, server, and more), Dart Native includes both a Dart VM with JIT (just-in-time) compilation and an AOT (ahead-of-time) compiler for producing machine code.
> * **Dart Web**: For programs targeting the web, Dart Web includes both a development time compiler (dartdevc) and a production time compiler (dart2js).
>
> From [dart-lang/sdk](https://github.com/dart-lang/sdk)

> [!WARNING]
> However, the internal workings of this library depends on `int` and `double`, but the constraints of these [types varies between `web` and `native`](https://dart.dev/language/built-in-types#numbers) which can cause anomalies when building a program for both of these platforms. Therefore, when targetting `web`, this library will utilize constants defined with `double` in [lib/src/web/shared.dart](./lib/src/web/shared.dart). On the other hand, when targeting `native`, `int` (64 bit) constants from [lib/src/native/shared.dart](./lib/src/native/shared.dart) will be used.

## Acknowledgements

### [Patashu/break_infinity.js](https://github.com/Patashu/break_infinity.js)
The original implementation

### [AD417/BreakInfinity.java](https://github.com/AD417/BreakInfinity.java)
Java port which helped porting it to Dart :)

### Contributors

<a href="https://github.com/exoad/break_infinity.dart/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=exoad/break_infinity.dart" />
</a>
