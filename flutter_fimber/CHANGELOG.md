## [0.6.6] - Version bump to match fimber/fimber_io

## [0.6.5] - Bug fixes

-- Update android dependencies to mavenCentral (from jcenter) [#116](https://github.com/magillus/flutter-fimber/issues/116)
-- Fix for Log without exception but with stack trace [#115](https://github.com/magillus/flutter-fimber/issues/115)

## [0.6.4] - Added log line/path to file to [CustomFormatTree]

-- Additional tokens for [CustomFormatTree] with filename/filepath log line and character.

## [0.6.3] - Fix for Android plugin with NonNull annotation

## [0.6.2] - Fix for channel name in Android side

## [0.6.1] - Build fix after fimber moved some files to `src`

## [0.6.0] - Update to null-safety channel

## [0.5.0-nullsafety.1] - Updated to Dart nullsafety.

## [0.4.4] - Fix for printing color when with level output 

Same as 0.4.3 - missed one usecase.

## [0.4.3] - Fix for printing color when with level output

- [\#78 issue](https://github.com/magillus/flutter-fimber/issues/78) Fixing coloring output on the formatted log output.

## [0.4.2] - Fixed versioning

- fixed versioning

## [0.4.1] - Bug fixes

- [\#75 issue](https://github.com/magillus/flutter-fimber/issues/75) - Fix for TimedRollingFileTree missing passed logLevels and logFormat
- [\#73 issue](https://github.com/magillus/flutter-fimber/issues/73) - Fix for mute levels list not being distinct

## 0.4.0 Update to match fimber io/base split.

## 0.3.2 AndroidX update and versions bump (thx: g123k)

## 0.3.1 Fixes incorrect Android package structure

## 0.3.0 Code style updates and bug fixes

## 0.2.0 Colorize logs

- Based on fimber 0.2.0 added colorized logs.

## 0.1.9 Kotlin and Gradle plugin version bump

- Kotlin version: `1.3.21`
- Gradle plugin version `3.3.1`

## 0.1.8 Support for stacktrace

- Support for stacktrace form `try catch` block from 0.1.8 `fimber` package

## 0.1.7 Following 0.1.7 build of `fimber`

* dynamic typ for `ex` paramter passed to log methods.

## 0.1.5 parity update with `fimber`

## 0.1.4 iOS update

* dump stacktrace for exception passed to log method

## 0.1.3 iOS plugin release

* iOS plugin part
* other 0.1.3 updates from Fimber

## 0.1.2 Android Plugin release for fimber dart logging

* First version with Android Log support
* Adds stacktrace from dart to std output when exception is passed
* Log levels passed through
