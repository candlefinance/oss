//
//  AppDelegate.swift
//  CallbackExample
//
//  Created by Gary Tokman on 9/2/24.
//

import React
//import candlefinance_callback
//import NitroModules

@UIApplicationMain
class AppDelegate : RCTAppDelegate {
  
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        self.moduleName = "CallbackExample"
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

//    let call = Callback()
//    let map = AnyMapHolder()
//    map.setObject(key: "notification", value: [:])
//    call.notify(map)
    if let view = window.rootViewController?.view {
      view.backgroundColor = .white
    }
        return result
    }

  override func bundleURL() -> URL? {
#if DEBUG
    print("DEBUG")
    return RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
#else
    print("PROD")
    return Bundle.main.url(forResource: "main", withExtension: "jsbundle")
#endif
  }

}
