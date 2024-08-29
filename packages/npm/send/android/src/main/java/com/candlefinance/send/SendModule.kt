package com.candlefinance.send

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = SendModule.NAME)
class SendModule(reactContext: ReactApplicationContext) :
  NativeSendSpec(reactContext) {

  override fun getName(): String {
    return NAME
  }

  override fun send(request: String?, promise: Promise?) {
    TODO("Not yet implemented")
  }

  companion object {
    const val NAME = "Send"
  }
}
