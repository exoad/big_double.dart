# break_infinity.dart
![Tests](https://img.shields.io/github/actions/workflow/status/exoad/break_infinity.dart/tests.yml?style=flat-square&label=native%20tests)

`BigInt` and `double` replacement that can hold up to 1e9e15 for Dart.

Dart port of [Patashu/break_infinity.js](https://github.com/Patashu/break_infinity.js)

<a href="https://www.buymeacoffee.com/exoad" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="width:170px" ></a>

## Usage
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

_**Voilà!**_ For more information on additional usage, read the documentation [here]().

## Compatibility & Limitations

**See [#1](https://github.com/exoad/break_infinity.dart/issues/1)**

This library primarily operates to support both `native` and `web` platforms. These platforms are as follows

> * **Dart Native**: For programs targeting devices (mobile, desktop, server, and more), Dart Native includes both a Dart VM with JIT (just-in-time) compilation and an AOT (ahead-of-time) compiler for producing machine code.
> * **Dart Web**: For programs targeting the web, Dart Web includes both a development time compiler (dartdevc) and a production time compiler (dart2js).
>
> From [dart-lang/sdk](https://github.com/dart-lang/sdk)

However, the internal workings of this library depends on `int` and `double`, but the constraints of these [types varies between `web` and `native`](https://dart.dev/language/built-in-types#numbers) which can cause anomalies when building
a program for both of these platforms. Therefore, when targetting `web`, this library will utilize constants defined with `double` in [lib/src/web/shared.dart](./lib/src/web/shared.dart). On the other hand, when targeting `native`, `int` (64 bit) constants from [lib/src/native/shared.dart](./lib/src/native/shared.dart) will be used.

## Acknowledgements

### [Patashu/break_infinity.js](https://github.com/Patashu/break_infinity.js)
The original implementation

### [AD417/BreakInfinity.java](https://github.com/AD417/BreakInfinity.java)
Java port which helped porting it to Dart :)

### Contributors

<a href="https://github.com/exoad/break_infinity.dart/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=exoad/break_infinity.dart" />
</a>
