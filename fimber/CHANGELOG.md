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
