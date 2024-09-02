import Foundation
import NitroModules

final public class Callback: HybridCallbackSpec {
    public var notify: ((AnyMapHolder) -> Void)?
    
    public var hybridContext = margelo.nitro.HybridContext()
    
    public var memorySize: Int {
        return getSizeOf(self)
    }
    
    public func onEvent(notify: @escaping ((AnyMapHolder) -> Void)) {
        self.notify = notify
    }
}
