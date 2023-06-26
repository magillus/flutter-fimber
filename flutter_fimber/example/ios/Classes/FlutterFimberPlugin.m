#import "FlutterFimberPlugin.h"
#import <flutter_fimber/flutter_fimber-Swift.h>

@implementation FlutterFimberPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterFimberPlugin registerWithRegistrar:registrar];
}
@end
