#import "Send.h"
#import "candlefinance_send-Swift.h"

@implementation Send
RCT_EXPORT_MODULE()

// Don't compile this code when we build for the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
- (void)send:(NSString *)request resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    SendSwift *send = [SendSwift new];
    [send sendWithStringifiedRequest:request resolve:resolve reject:reject];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeSendSpecJSI>(params);
}
#endif

@end
