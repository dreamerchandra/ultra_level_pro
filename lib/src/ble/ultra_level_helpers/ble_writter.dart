import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/constant.dart';

class BleWriter {
  final FlutterReactiveBle ble;

  BleWriter({required this.ble});
  Future<String> listenToEcho(String deviceId) async {
    final txCh = QualifiedCharacteristic(
      serviceId: UART_UUID,
      characteristicId: UART_TX,
      deviceId: deviceId,
    );

    Completer<String> completer = Completer<String>();
    final subscription = ble.subscribeToCharacteristic(txCh).listen((data) {
      final res = String.fromCharCodes(data);
      completer.complete(res);
    }, onError: (dynamic error) {
      completer.completeError(error);
    });
    completer.future.then((_) {
      subscription.cancel();
    }, onError: (_) {
      subscription.cancel();
    });
    return completer.future;
  }

  bool checkWriteIsOk(
      {required String desiredValue, required String actualValue}) {
    return true;
  }

  String getValueToWrite(WriteParameter parameter, String value) {
    switch (parameter) {
      case WriteParameter.BaudRate:
        return 'AT+BAUD4';
      case WriteParameter.Damping:
        return 'AT+DAMP0';
      case WriteParameter.Settings:
        return 'AT+SET0';
      case WriteParameter.LowLevelRelayInMm:
        return 'AT+LLR$value';
      case WriteParameter.HighLevelRelayInPercent:
        return 'AT+HLR$value';
      case WriteParameter.Lph:
        return 'AT+LPH$value';
      case WriteParameter.ZeroPercentTrimmingPoint:
        return 'AT+ZPT$value';
      case WriteParameter.HundredPercentTrimmingPoint:
        return 'AT+HPT$value';
      case WriteParameter.LevelCalibrationOffset:
        return 'AT+LCO$value';
      case WriteParameter.SensorOffset:
        return 'AT+SO$value';
      case WriteParameter.TankOffset:
        return 'AT+TO$value';
      case WriteParameter.TankType:
        return 'AT+TT$value';
      case WriteParameter.TankHeight:
        return 'AT+TH$value';
      case WriteParameter.TankWidth:
        return 'AT+TW$value';
      case WriteParameter.TankLength:
        return 'AT+TL$value';
      case WriteParameter.SlaveId:
        return 'AT+SID$value';
    }
  }

  Future<bool> writeToDevice(
      {required String deviceId,
      required WriteParameter parameter,
      required String value}) async {
    final valueToWrite = getValueToWrite(parameter, value);

    Completer<bool> completer = Completer<bool>();
    verifyEcho(value) {
      if (checkWriteIsOk(actualValue: value, desiredValue: valueToWrite)) {
        completer.complete(true);
      } else {
        throw Exception('Write failed');
      }
    }

    handleError(error, stackTrace) {
      completer.completeError(error);
    }

    listenToEcho(deviceId).then(verifyEcho).onError(handleError);

    final rxCh = QualifiedCharacteristic(
      serviceId: UART_UUID,
      characteristicId: UART_RX,
      deviceId: deviceId,
    );
    ble.writeCharacteristicWithResponse(rxCh, value: valueToWrite.codeUnits);
    return completer.future;
  }
}
