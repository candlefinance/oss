import Foundation
import PINCache
import NitroModules

final class Cache: HybridCacheSpec {
    
    var hybridContext = margelo.nitro.HybridContext()
    
    var memorySize: Int {
        return getSizeOf(self)
    }
    
    func clear() {
        PINCache.shared.removeAllObjects()
    }
    
    func clearAsync() throws -> Promise<Void> {
        return Promise.async {
            await PINCache.shared.removeAllObjectsAsync()
        }
    }
    
    func read(key: String) -> String? {
        return PINCache.shared.object(forKey: key) as? String
    }
    
    func readAsync(key: String) throws -> Promise<String?> {
        return Promise.async {
            let (_, _, value) = await PINCache.shared.object(forKeyAsync: key)
            return value as? String
        }
    }
    
    func write(key: String, object: String) {
        PINCache.shared.setObject(object, forKey: key)
    }
    
    func writeAsync(key: String, object: String) throws -> Promise<Void> {
        return Promise.async {
            await PINCache.shared.setObjectAsync(object, forKey: key)
        }
    }
    
    func remove(key: String) {
        PINCache.shared.removeObject(forKey: key)
    }
    
    func removeAsync(key: String) throws -> Promise<Void> {
        return Promise.async {
            await PINCache.shared.removeObject(forKeyAsync: key)
        }
    }
    
}
