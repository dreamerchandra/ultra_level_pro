import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_non_linear_state.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_writter.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/helper.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/settings.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/tank_type.dart';

class TankTypeParameter {
  WriteParameter parameter;
  String value;
  TankTypeParameter({required this.parameter, required this.value});
}

//slaveId(01)+funcode(10)+startAdd(4500)+len(number of point + 1)+byteCount(len*2)+data(eg len,point 1 in height, point 1 filled....poinnt n)+crc
//

class NonLinearBleWriter extends BleWriter {
  List<NonLinearParameter> _valuesToCommit = [];

  NonLinearBleWriter({required super.ble});

  void update(List<NonLinearParameter> val) {
    _valuesToCommit = val;
  }

  String constructMultiPartWrite({
    required Settings settings,
    required String deviceId,
    required String slaveId,
  }) {
    final values = _valuesToCommit
        .map((parameter) {
          final height = constructData(
            value: '${parameter.height}',
            parameter: WriteParameter.TankHeight,
            settings: settings,
          );
          final filled = constructData(
            value: '${parameter.filled}',
            parameter: WriteParameter.TankHeight,
            settings: settings,
          );
          return '$height$filled';
        })
        .toList()
        .join();
    String startAdd = '01f4'; // hex(500) -> 01f3;
    String len = ensure2Byte(intToHex(_valuesToCommit.length + 1));
    String byteCount = ensure1Byte('${(values.length) * 2}');
    String data = '$startAdd$len$byteCount$values';
    String header = '${slaveId}10'; // slaveId funCode writeAddress data crc

    final crc = calculateModbusCRC((header + data));
    final valueToWrite = header + data + crc;
    return valueToWrite;
  }

  Future<bool> multiWriteCommitHelper(String valueToWrite, String deviceId) {
    Completer<bool> completer = Completer<bool>();
    verifyEcho(String echoValue) {
      debugPrint('Echo value $echoValue');
      if (checkWriteIsOk(
        actualValue: echoValue.substring(0, 12),
        desiredValue: echoValue.substring(0, 12),
      )) {
        completer.complete(true);
        debugPrint("Write successfull");
        // throw Exception("Make sure to rewrite check write is ok");
      } else {
        throw Exception('Write failed');
      }
    }

    handleError(error, stackTrace) {
      completer.completeError(error);
    }

    listenToEcho(deviceId).then(verifyEcho).onError(handleError);
    debugPrint("starting to write $valueToWrite");

    final rxCh = QualifiedCharacteristic(
      serviceId: UART_UUID,
      characteristicId: UART_RX,
      deviceId: deviceId,
    );
    ble.writeCharacteristicWithResponse(rxCh,
        value: valueToWrite.toUpperCase().codeUnits);
    return completer.future;
  }

  Future<bool> commitTankType({
    required String deviceId,
    required Settings settings,
    required String slaveId,
  }) async {
    final nonLinearData = constructData(
      value: getTankTypeInHex(TankType.nonLinear),
      parameter: WriteParameter.TankType,
      settings: settings,
    );
    final data = constructWrite(
      deviceId: deviceId,
      slaveId: slaveId,
      parameter: WriteParameter.TankType,
      value: nonLinearData,
      settings: settings,
    );
    await super.commitHelper(data, deviceId);
    Completer<bool> completer = Completer<bool>();
    Future.delayed(Duration(milliseconds: 100), () async {
      final valueToWrite = constructMultiPartWrite(
        settings: settings,
        deviceId: deviceId,
        slaveId: slaveId,
      );
      var commitHelper = await multiWriteCommitHelper(valueToWrite, deviceId);
      completer.complete(commitHelper);
    });
    return completer.future;
  }
}
