#import "HybridCacheSpecSwift.hpp"
#import "HybridCacheSpec.hpp"
#import <NitroModules/HybridObjectRegistry.hpp>
#import <Foundation/Foundation.h>

namespace NitroCache {
class NitroSendRegistry;
} // namespace NitroImage

#import "candlefinance_cache-Swift-Cxx-Umbrella.hpp"

@interface NitroCacheOnLoad : NSObject
@end

@implementation NitroCacheOnLoad : NSObject

using namespace margelo::nitro;
using namespace candlefinance_cache;

+ (void)load {
    HybridObjectRegistry::registerHybridObjectConstructor("Cache", []() -> std::shared_ptr<HybridObject> {
        auto obj = CacheNitroRegistry::createCacheObject();
        return std::make_shared<cache::HybridCacheSpecSwift>(obj);
    });
}

@end