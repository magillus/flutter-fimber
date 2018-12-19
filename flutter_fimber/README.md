# Flutter plug-in for Fimber

This plug-in will make the logging via Fimber into native OS logging output.

## Getting Started - import 

### Dependency setup
```yaml
  flutter_fimber: ^0.1.7
```
### Import setup
```dart
import 'package:flutter_fimber/flutter_fimber.dart';
```
### Plant a log tree

In code on start of your application add `FimberTree` like this:
```dart
  Fimber.plantTree(FimberTree());
``` 

iOS and Android platforms supported.

For more usage see [Fimber project](https://pub.dartlang.org/packages/fimber)
