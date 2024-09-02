package com.candlefinance.send

import android.content.Context
import android.util.Log
import com.facebook.react.TurboReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfoProvider
import com.margelo.nitro.core.HybridObjectRegistry

class SendPackage() : TurboReactPackage() {
  override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? {
    return null
  }

  init {
//    HybridObjectRegistry.registerHybridObjectConstructor("Send") {
//      Log.i("YEET", "initializing Send...")
//      val f: SendModule = SendModule(Context())
//      Log.i("YEET", "done Send!")
//      f
//    }
  }

  override fun getReactModuleInfoProvider(): ReactModuleInfoProvider {
    return ReactModuleInfoProvider { HashMap() }
  }
}
