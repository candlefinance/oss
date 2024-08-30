import Foundation
import PINCache
import NitroModules

final class Cache: HybridCacheSpec {
    
    var hybridContext = margelo.nitro.HybridContext()
    
    var memorySize: Int {
        return getSizeOf(self)
    }
    
    func clear() throws -> Promise<Void> {
        return Promise.async {
            PINCache.shared.removeAllObjects()
        }
    }
    
    func read(key: String) throws -> Promise<String?> {
        return Promise.async {
            return PINCache.shared.object(forKey: key) as? String
        }
    }
    
    func write(key: String, value: String) throws -> Promise<Void> {
        return Promise.async {
            PINCache.shared.setObject(value, forKey: key)
        }
    }
    
    func remove(key: String) throws -> Promise<Void> {
        return Promise.async {
            PINCache.shared.removeObject(forKey: key)
        }
    }
    
}
