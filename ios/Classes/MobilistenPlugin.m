#import "MobilistenPlugin.h"
#import <Mobilisten/Mobilisten.h>
#if __has_include(<mobilisten_plugin/mobilisten_plugin-Swift.h>)
#import <mobilisten_plugin/mobilisten_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "mobilisten_plugin-Swift.h"
#endif

@implementation MobilistenPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [SwiftMobilistenPlugin registerWithRegistrar:registrar];
    [SwiftMobilistenPlugin setEmptyChatInstance:[SIQVisitorChat alloc]];
}
@end
