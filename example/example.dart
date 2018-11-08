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
}
