package com.candlefinance.send

import com.margelo.nitro.candlefinance_send.HybridSendSpec
import com.margelo.nitro.candlefinance_send.Request
import com.margelo.nitro.candlefinance_send.SendResult

class SendModule(): HybridSendSpec() {

  override val memorySize: Long
    get() = 0

  override fun send(request: Request): com.margelo.nitro.core.Promise<SendResult> {
    TODO("Not yet implemented")
  }

  companion object {
    const val NAME = "Send"
  }
}
