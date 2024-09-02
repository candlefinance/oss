#import "HybridCallbackSpecSwift.hpp"
#import "HybridCallbackSpec.hpp"
#import <NitroModules/HybridObjectRegistry.hpp>
#import <Foundation/Foundation.h>

namespace NitroCallback {
class NitroCallbackRegistry;
} // namespace NitroImage

#import "candlefinance_callback-Swift-Cxx-Umbrella.hpp"

@interface NitroOnLoad : NSObject
@end

@implementation NitroOnLoad : NSObject

using namespace margelo::nitro;
using namespace candlefinance_callback;

+ (void)load {
    HybridObjectRegistry::registerHybridObjectConstructor("Callback", []() -> std::shared_ptr<HybridObject> {
        auto obj = NitroRegistry::createObject();
        return std::make_shared<callback::HybridCallbackSpecSwift>(obj);
    });
}

@end
