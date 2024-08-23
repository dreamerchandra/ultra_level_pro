import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ultra_level_pro/ble/turn_on_ble.dart';
import 'package:ultra_level_pro/constants/text_style.dart';

class BleStatusWidget extends StatelessWidget {
  const BleStatusWidget({Key? key, required this.bleStatus}) : super(key: key);
  final BleStatus bleStatus;
  @override
  Widget build(BuildContext context) {
    if (bleStatus == BleStatus.unknown) {
      return const Center(child: CircularProgressIndicator());
    } else if (bleStatus == BleStatus.unsupported) {
      return const Center(
          child: Text(
        "Your device isn't supported",
        style: header1,
      ));
    } else if (bleStatus == BleStatus.poweredOff) {
      return Center(
          child: Column(
        children: [
          const Text(
            "Bluetooth is currently disabled.",
            style: header1,
          ),
          ElevatedButton(
              onPressed: () {
                BleDeviceController.turnOn();
              },
              child: const Text("Turn ON")),
        ],
      ));
    } else if (bleStatus == BleStatus.unauthorized) {
      return const Center(
          child: Text(
        "Please authorize bluetooth in settings",
        style: header1,
      ));
    } else if (bleStatus == BleStatus.locationServicesDisabled) {
      return const Center(
          child: Text(
        "Please turn on location services",
        style: header1,
      ));
    }
    return const Center(child: CircularProgressIndicator());
  }
}
