import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

final textStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Colors.primaries[0].shade900,
);

class BleStatusWidget extends StatelessWidget {
  const BleStatusWidget({Key? key, required this.bleStatus}) : super(key: key);
  final BleStatus bleStatus;
  @override
  Widget build(BuildContext context) {
    if (bleStatus == BleStatus.unknown) {
      return const Center(child: CircularProgressIndicator());
    } else if (bleStatus == BleStatus.unsupported) {
      return Center(
          child: Text(
        "Your device isn't supported",
        style: textStyle,
      ));
    } else if (bleStatus == BleStatus.poweredOff) {
      return Center(
          child: Text(
        "Please turn on your bluetooth",
        style: textStyle,
      ));
    } else if (bleStatus == BleStatus.unauthorized) {
      return Center(
          child: Text(
        "Please authorize bluetooth in settings",
        style: textStyle,
      ));
    } else if (bleStatus == BleStatus.locationServicesDisabled) {
      return Center(
          child: Text(
        "Please turn on location services",
        style: textStyle,
      ));
    }
    return const Center(child: CircularProgressIndicator());
  }
}
