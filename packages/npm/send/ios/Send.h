
#ifdef RCT_NEW_ARCH_ENABLED
#import "SendSpec.h"

@interface Send : NSObject <NativeSendSpec>
#else
#import <React/RCTBridgeModule.h>

@interface Send : NSObject <RCTBridgeModule>
#endif

@end
