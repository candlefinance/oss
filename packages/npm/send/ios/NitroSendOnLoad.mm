#import "HybridSendSpecSwift.hpp"
#import "HybridSendSpec.hpp"
#import <NitroModules/HybridObjectRegistry.hpp>
#import <Foundation/Foundation.h>

namespace NitroSend {
class NitroSendRegistry;
} // namespace NitroImage

#import "candlefinance_send-Swift-Cxx-Umbrella.hpp"

@interface NitroSendOnLoad : NSObject
@end

@implementation NitroSendOnLoad : NSObject

using namespace margelo::nitro;

+ (void)load {
    HybridObjectRegistry::registerHybridObjectConstructor("Send", []() -> std::shared_ptr<HybridObject> {
        auto obj = candlefinance_send::SendNitroRegistry::createSendObject();
        return std::make_shared<send::HybridSendSpecSwift>(obj);
    });
}

@end
