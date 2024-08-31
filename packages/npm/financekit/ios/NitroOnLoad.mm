#import "HybridFinanceKitSpecSwift.hpp"
#import "HybridFinanceKitSpec.hpp"
#import <NitroModules/HybridObjectRegistry.hpp>
#import <Foundation/Foundation.h>

namespace NitroFinanceKit {
class NitroFinanceKitRegistry;
} // namespace NitroImage

#import "candlefinance_financekit-Swift-Cxx-Umbrella.hpp"

@interface NitroFinanceKitOnLoad : NSObject
@end

@implementation NitroOnLoad : NSObject

using namespace margelo::nitro;
using namespace candlefinance_financekit;

+ (void)load {
    // HybridObjectRegistry::registerHybridObjectConstructor("FinanceKit", []() -> std::shared_ptr<HybridObject> {
    //     auto obj = FinanceKitNitroRegistry::createObject();
    //     return std::make_shared<financekit::HybridFinanceKitSpecSwift>(obj);
    // });
}

@end
