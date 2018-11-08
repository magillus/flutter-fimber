# fimber 

Extensible logging for Flutter.

Based on famous Android logging library - [Timber](https://github.com/JakeWharton/timber), this is library for simplify logging for Flutter.
Using similar (as far as Dart lang allows) method API with same concepts for tree and planting logging tree.

## Getting Started

To start add using it:
- Add `fimber` to `pubspec.yaml` 
```yaml
dependencies:
  fimber: ^0.1.0
  ```

- Start using it with static methods:

```dart
import 'fimber.dart';


void main() {
  var parameter = 343.0;
  // use directly
  Fimber.i("Test message $argument");
  Fimber.i("Extra error message", ex: Exception("Test thorwable"));
  
  // other log levels
  Fimber.d("DEBUG");
  Fimber.v("VERBOSE");
  Fimber.w("WARN");
  
}

```

This will log the value and grab a TAG from stacktrace - that is little costly and if more logs will be done per second.

- Create tagged version of Fimber and use its instance inside class, you can create logger for a dart file or for a class.

```dart
var logger = FimberLog("MY_TAG");

void main() {
  
  logger.d("Test message");
}

// or inside a class
class SomeBloc {
  var logger = FimberLog("SomeBloc");
  String fetchMessage() {
    logger.d("About to fetch some data.");
    //...
    var data = "load something";

    logger.d("Retrived data (len = ${data.length}");
    return data;
  }
}
```


## TODO - road map

- un-plant single tree
- Make this Dart only Logger and use flutter dependency only for plugins
- Add Tree for platform specific log/tag logging via channels - plugins
- Add Crashlytics plugin (maybe other remote logger tools) with [flutter_crashlytics](https://pub.dartlang.org/packages/flutter_crashlytics)


