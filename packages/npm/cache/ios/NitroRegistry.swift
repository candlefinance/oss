import Foundation

public class CacheNitroRegistry {
  public static func createCacheObject() -> HybridCacheSpecCxx {
    return HybridCacheSpecCxx(Cache())
  }
}
