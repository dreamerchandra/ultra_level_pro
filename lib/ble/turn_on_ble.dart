import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BleDeviceController {
  static Future<void> turnOn() async {
    try {
      const result = AndroidIntent(
        action:
            'android.bluetooth.adapter.action.REQUEST_ENABLE', // Bluetooth enable action
      );
      return result.launch();
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
  }
}
