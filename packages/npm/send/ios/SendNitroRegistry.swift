import Foundation

public class SendNitroRegistry {
  public static func createSendObject() -> HybridSendSpecCxx {
    return HybridSendSpecCxx(Send())
  }
}
