import 'package:fimber/fimber.dart';

void main() {
  // plant a tree - DebugTree()
  Fimber.plantTree(DebugTree());

  Fimber.d("Test message", ex: Exception("test error"));
  var parameter = 100.0;
  Fimber.w("Test message with parameter: $parameter");

  var logger = FimberLog("MY_TAG");
  logger.d("Test message", ex: Exception("test error"));
  logger.w("Test message with parameter: $parameter");

  try {
    throw Exception("Exception thrown");
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
