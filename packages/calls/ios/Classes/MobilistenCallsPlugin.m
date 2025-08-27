#import "MobilistenCallsPlugin.h"
#import <MobilistenCalls/MobilistenCalls.h>
#import <MobilistenCallsCore/MobilistenCallsCore.h>

//#import <Mobilisten/Mobilisten.h>
#if __has_include(<salesiq_mobilisten_calls/salesiq_mobilisten_calls-Swift.h>)
#import <salesiq_mobilisten_calls/salesiq_mobilisten_calls-Swift.h>

#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "salesiq_mobilisten_calls-Swift.h"

#endif

@implementation MobilistenCallsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [SwiftMobilistenCallsPlugin registerWithRegistrar:registrar];
//    [SwiftMobilistenCallsPlugin setEmptyChatInstance:[SIQVisitorChat alloc]];
}
@end
