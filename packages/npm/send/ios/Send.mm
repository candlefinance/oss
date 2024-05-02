#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(Send, NSObject)

RCT_EXTERN_METHOD(send:(NSString *)request
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

@end
