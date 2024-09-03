import Foundation

@available(iOS 17.4, *)
public class NitroRegistry {
  public static func createObject() -> HybridFinanceKitSpecCxx {
    return HybridFinanceKitSpecCxx(FinanceKit())
  }
}
