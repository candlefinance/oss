#import "Send.h"
#import "candlefinance_send-Swift.h"

@interface Send ()
@property (nonatomic, strong) SendSwift *sendSwiftInstance;
@end

@implementation Send
RCT_EXPORT_MODULE()

- (instancetype)init {
    self = [super init];
    if (self) {
        _sendSwiftInstance = [SendSwift new];
    }
    return self;
}

// Don't compile this code when we build for the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
- (void)send:(NSString *)request resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [self.sendSwiftInstance sendWithStringifiedRequest:request resolve:resolve reject:reject];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeSendSpecJSI>(params);
}
#endif

@end
