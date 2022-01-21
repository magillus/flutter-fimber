## [0.6.5] - Bug fixes

-- Update android dependencies to mavenCentral (from jcenter) [#116](https://github.com/magillus/flutter-fimber/issues/116)
-- Fix for Log without exception but with stack trace [#115](https://github.com/magillus/flutter-fimber/issues/115)

## [0.6.4] - Added log line/path to file to [CustomFormatTree]

-- Additional tokens for [CustomFormatTree] with filename/filepath log line and character.

## [0.6.3] - SizeRollingFileTree bug fix

-- [\#86](https://github.com/magillus/flutter-fimber/issues/86) - fix for this bug

## [0.6.2] - Build and merge fix

## [0.6.1-dev] Network Logger dev release

- Added TCP/UDB socket loggers that allow network based connection to send logs.

## [0.6.1] - Build fix

## [0.6.0] - Release to null-safety on stable

- Update to null-safety support on stable channel

## [0.5.0-nullsafety.1] - Updated to support dart null-safety

- No other fixes/updates, just null-safety

## [0.4.4] - Fix for printing color when with level output 

Same as 0.4.3 - missed one usecase.

## [0.4.3] - Fix for printing color when with level output

- [\#78 issue](https://github.com/magillus/flutter-fimber/issues/78) Fixing coloring output on the formatted log output.

## [0.4.2] - Fixed versioning

- fixed versioning

## [0.4.1] - Bug fixes

- [\#75 issue](https://github.com/magillus/flutter-fimber/issues/75) - Fix for TimedRollingFileTree missing passed logLevels and logFormat
- [\#73 issue](https://github.com/magillus/flutter-fimber/issues/73) - Fix for mute levels list not being distinct

## 0.4.0 Fimber dependency on dart::io separated

- moved all File based and dart::io package dependent code from `fimber` to `fimber_io`

## 0.3.3 fimber_io split from fimber package


