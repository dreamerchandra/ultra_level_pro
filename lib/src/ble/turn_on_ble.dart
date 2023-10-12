import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BleDeviceController {
  static const platform = MethodChannel('ultra_level_pro.flutter.dev/ble');

  // Future<void> turnOnBlueTooth() async {
  //   try {
  //     await platform.invokeMethod('turnOnBle');
  //   } on PlatformException catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  Future<void> inFlutter() async {
    try {
      final result = const AndroidIntent(
        action:
            'android.bluetooth.adapter.action.REQUEST_ENABLE', // Bluetooth enable action
      );
      return result.launch();
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
  }
}
