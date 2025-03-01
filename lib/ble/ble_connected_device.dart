import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BleConnectedDevice {
  final String? name;
  final String? id;
  final int? rssi;

  BleConnectedDevice({
    this.name,
    this.id,
    this.rssi,
  });

  static BleConnectedDevice create(DiscoveredDevice device) {
    return BleConnectedDevice(
      name: device.name,
      id: device.id,
      rssi: device.rssi,
    );
  }
}

class BleConnectedDeviceNotifier extends StateNotifier<BleConnectedDevice?> {
  BleConnectedDeviceNotifier() : super(null);

  void setDevice(DiscoveredDevice device) {
    state = BleConnectedDevice.create(device);
  }

  void clearDevice() {
    state = null;
  }
}
