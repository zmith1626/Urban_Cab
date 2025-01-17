package com.example.expange

import android.os.Bundle
import android.view.ViewTreeObserver
import android.view.WindowManager
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    // make transparent status bar
    window.statusBarColor = 0x00000000
    GeneratedPluginRegistrant.registerWith(this)
    // Remove full screen flag after load
    val vto = flutterView.viewTreeObserver
    vto.addOnGlobalLayoutListener(object : ViewTreeObserver.OnGlobalLayoutListener {
      override fun onGlobalLayout() {
        flutterView.viewTreeObserver.removeOnGlobalLayoutListener(this)
        window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
      }
    })
  }
}
