
import Foundation

public class NitroRegistry {
  public static func createObject() -> HybridCallbackSpecCxx {
    return HybridCallbackSpecCxx(Callback())
  }
}
