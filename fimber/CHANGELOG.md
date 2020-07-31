## [0.4.4] - Fix for printing color when with level output 

Same as 0.4.3 - missed one usecase.

## [0.4.3] - Fix for printing color when with level output

- [\#78 issue](https://github.com/magillus/flutter-fimber/issues/78) Fixing coloring output on the formatted log output.

## [0.4.2] - Fixed versioning

- fixed versioning

## [0.4.1] - Bug fixes

- [\#75 issue](https://github.com/magillus/flutter-fimber/issues/75) - Fix for TimedRollingFileTree missing passed logLevels and logFormat
- [\#73 issue](https://github.com/magillus/flutter-fimber/issues/73) - Fix for mute levels list not being distinct

## [0.4.0] - Release of Fimber ready for Web (JS/FlutterWeb)

- Moving File loggers to separate [`fimber_io`](https://pub.dev/packages/fimber_io/) package
- Clean up

## [0.4.0-dev] - Removing dependency on dart::io.

- If want to use File loggers use [`fimber_io`](https://pub.dev/packages/fimber_io/) package

## [0.3.3] - Deprecating dart:io dependency

- Removing FileLogging and moving it to separate package: `fimber_io`
- 0.4.0 version will remove dependency on dart::io - so that Fimber can be used in Web projects.

## [0.3.2] - Bug fix for Time rolling tree.

- [\#52 issue](https://github.com/magillus/flutter-fimber/issues/52)  Fix for check of new file format based on timeSpan intervals.

## [0.3.1] - Bug fixes around File rolling tree

- initialize `outputFileName` variable  by [@sceee](https://github.com/sceee)
- removed unnecessary async that caused SizeRollingFileTree constructor to not construct the first logfile correctly before writes to the uninitialized filename could happen by [@sceee](https://github.com/sceee) 

## [0.3.0] - Code styles updates and bug fixes

- Code styles updates based on pedantic lint rules.
- bug fix for TAG generation taking from correct stacktrace location = index 4.

## [0.2.1] - Auto create directory for log files

## [0.2.0] - Colorize logs  

- Added ANSI colorized option for `DebugTree` and `CustomFormatTree` (by default it is disabled)
- `AnsiStyle` classes as extra for adding any colorful output for console.

## [0.1.11] - FileLog bugfix

- FileLog bug fix for conflicts on file append. 
- FileLog uses flush buffer as temporary storage and writes to disk in 2 cases: 1 every 500ms and when ever buffer size exceeds 1kB.
- Added unit tests for new bug.
- docs update

## [0.1.10] - FileLog append fix, mute levels

- bug fix for file log bug where new lines were overriding file not append lines.
- Added log level muting from `Fimber.mute` and `Fimber.unmute`  

## [0.1.9] - CustomFormatTree and FileLogTree 

- Custom format tree and File logging tree based on custom format. This will allow DartVM apps to output to defined file.

## [0.1.8] - Support for stacktrace optional parameter

- Stacktrace optional parameter after adding `ex` can be provided from `try catch` block's second parameter 
```dart
try {
  ...
} catch (ex, stacktrace) {
  Fimber.e("log message", ex:ex, stacktrace: stacktrace);  
}

```
## [0.1.7] - Changed the `ex` class

- Accepting dynamic (any class) on `ex` property of Logger. 
This allows to pass Error or Exception or any other value to log statement - `toString()` is used for printout

## [0.1.6] - DebugTree time options

- Added Elapsed time option for debug tree logging (useful for server side/dart vm logging)
- Added Time option for debug tree

## [0.1.5] - bug fixes 

- Bug fix for log tag auto creation inside constructor.
- Added tests for factory method logging after constructor log tag fix.

## [0.1.4] - iOS exception stacktrace logging

- no update on fimber, only mirror update for flutter_fimber iOS plugin

## [0.1.3] - iOS plugin part for logging

- Added support for iOS log output.
- Un-plant tree option.
- Block function operation.

## [0.1.2] - only dart package form `fimber`

- Small changes around packaging and removing any flutter references.
- Revert to print from debugPrint for dart only support.
- DebugTree got printLog method to override to support other solution to print formatted log line tou output stream, will be helpful in AndroidDebugTree (for example).
- Updates to stacktrace dumping for DebugTree and added method to extract stacktrace.

## [0.1.1] - Small updates

Small updates 

## [0.1.0] - First Version

Initial version with Fimber debugging and DebugTree
