#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(Prefs, NSObject)

RCT_EXTERN_METHOD(getPref:(NSString *)key withResolver:(RCTPromiseResolveBlock)resolve withRejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(setPref:(NSString *)key toValue:(NSString *)value withResolver:(RCTPromiseResolveBlock)resolve withRejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(deletePref:(NSString *)key withResolver:(RCTPromiseResolveBlock)resolve withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
