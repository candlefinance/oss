private let CODE_NON_STRING_VALUE = "@candlefinance.prefs.non_string_value"
private let MESSAGE_NON_STRING_VALUE = "UserDefaults value was found, but is not a string. You can use deletePref() to remove the existing value and try again. If you're setting this value from native iOS code, make sure to pass a String to set()."

@objc(Prefs)
class Prefs: NSObject {
    
    @objc(getPref:withResolver:withRejecter:)
    func getPref(key: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        let anyValue = UserDefaults.standard.object(forKey: key)
        guard let stringValue = anyValue as? String? else {
            return reject(CODE_NON_STRING_VALUE, MESSAGE_NON_STRING_VALUE, nil)
        }
        resolve(stringValue)
    }
    
    @objc(setPref:toValue:withResolver:withRejecter:)
    func setPref(key: String, toValue value: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        UserDefaults.standard.set(value, forKey: key)
        resolve(nil)
    }
    
    @objc(deletePref:withResolver:withRejecter:)
    func deletePref(key: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        UserDefaults.standard.removeObject(forKey: key)
        resolve(nil)
    }
}
