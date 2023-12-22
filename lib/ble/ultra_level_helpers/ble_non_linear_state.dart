import 'package:flutter/material.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/helper.dart';

class NonLinearParameter {
  final int height;
  final int filled;

  NonLinearParameter({required this.height, required this.filled});
}

class BleNonLinearState {
  late List<NonLinearParameter> nonLinearParameters;
  final String data;
  bool isCRCSame() {
    final crcFromDevice = data.substring(data.length - 4);
    final dataToBeComputed = data.substring(0, data.length - 4);
    if (crcFromDevice == calculateModbusCRC(dataToBeComputed)) return true;
    debugPrint('crc from device: $crcFromDevice');
    debugPrint('our crc: ${calculateModbusCRC(dataToBeComputed)}');
    return false;
  }

  BleNonLinearState({required this.data}) {
    if (!isCRCSame()) throw Exception("CRC is not same");
    computeValues();
  }

  void computeValues() {
    nonLinearParameters = [];
    int dataI = 8;
    while (dataI < data.length - 16) {
      final height = int.parse(data.substring(dataI, dataI += 4), radix: 16);
      final filled = int.parse(data.substring(dataI, dataI += 4), radix: 16);
      nonLinearParameters
          .add(NonLinearParameter(height: height, filled: filled));
    }
  }
}
