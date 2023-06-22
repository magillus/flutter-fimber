import 'package:fimber/fimber.dart';

void main() {
  // plant a tree - DebugTree()
  Fimber.plantTree(DebugTree());

  Fimber.d("Test message", ex: Exception("test error"));
  const parameter = 100.0;
  Fimber.w("Test message with parameter: $parameter");

  final logger = FimberLog("MY_TAG");
  logger.d("Test message", ex: Exception("test error"));
  logger.w("Test message with parameter: $parameter");

  try {
    throw Exception("Exception thrown");
    // ignore: avoid_catches_without_on_clauses
  } catch (e, stacktrace) {
    // providing stacktrace will better show where issue was thrown
    Fimber.i("Error caught.", ex: e, stacktrace: stacktrace);
  }
  // save time without auto tag generation on each call in call block.
  Fimber.withTag("TEST BLOCK", (log) {
    log.d("Started block");
    for (var i = 0; i >= 1; i++) {
      log.d("value: $i");
    }
    log.i("End of block");
  });
}
