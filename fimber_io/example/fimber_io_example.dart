import 'package:fimber_io/fimber_io.dart';

void main() {
  // todo example with files.
  Fimber.plantTree(FimberFileTree.elapsed("test.log"));

  Fimber.i("Test log");
  Fimber.d("Test DEBUG");
}
