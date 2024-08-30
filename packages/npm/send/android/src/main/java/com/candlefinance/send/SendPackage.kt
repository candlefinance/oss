package com.candlefinance.send

import com.facebook.react.TurboReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider
import java.util.HashMap

class SendPackage : TurboReactPackage() {
  override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? {
    return null
  }

  override fun getReactModuleInfoProvider(): ReactModuleInfoProvider {
    return ReactModuleInfoProvider {
      val moduleInfos: MutableMap<String, ReactModuleInfo> = HashMap()
//      moduleInfos[SendModule.NAME] = ReactModuleInfo(
//        SendModule.NAME,
//        SendModule.NAME,
//        false,  // canOverrideExistingModule
//        false,  // needsEagerInit
//        true,  // hasConstants
//        false,  // isCxxModule
//        true // isTurboModule
//      )
      moduleInfos
    }
  }
}
