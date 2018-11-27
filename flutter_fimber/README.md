# flutter_fimber Flutter pluging for Fimber

This plugin will make the logging via Fimber into native OS logging output.

*Note* 
Supported only on Android as of right now.


## Getting Started - import 

### Dependency setup
```yaml
  flutter_fimber: ^0.1.3
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

### Use as normal Fimber

For more usage see [Fimber project](https://pub.dartlang.org/packages/fimber)
