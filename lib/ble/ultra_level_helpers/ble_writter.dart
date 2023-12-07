import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/helper.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/settings.dart';

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

  bool checkWriteIsOk({
    required String desiredValue,
    required String actualValue,
  }) {
    return desiredValue.toUpperCase() == actualValue.toUpperCase();
  }

  String constructWrite({
    required String deviceId,
    required WriteParameter parameter,
    required String value,
    required Settings settings,
    required String slaveId,
    SettingsValueToChange? settingsValueToChange,
  }) {
    final writeAddress = ParameterToAddress[parameter];
    String header =
        '${slaveId}06$writeAddress'; // slaveId funCode writeAddress data crc
    final data = constructData(
      value: value,
      parameter: parameter,
      settingsValueToChange: settingsValueToChange,
      settings: settings,
    );
    final crc = calculateModbusCRC((header + data));
    final valueToWrite = header + data + crc;
    return valueToWrite;
  }

  Future<bool> commitHelper(String valueToWrite, String deviceId) {
    Completer<bool> completer = Completer<bool>();
    verifyEcho(String echoValue) {
      if (checkWriteIsOk(
        actualValue: echoValue.substring(0, valueToWrite.length),
        desiredValue: valueToWrite,
      )) {
        completer.complete(true);
        debugPrint("Write successfull");
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

  Future<bool> writeToDevice({
    required String deviceId,
    required WriteParameter parameter,
    required String value,
    required Settings settings,
    required String slaveId,
  }) async {
    final valueToWrite = constructWrite(
        deviceId: deviceId,
        parameter: parameter,
        settings: settings,
        slaveId: slaveId,
        value: value); // voltage, 251

    return commitHelper(valueToWrite, deviceId);
  }

  Future<bool> writeSettingsToDevice({
    required String deviceId,
    required Settings oldSettings,
    required String slaveId,
    required SettingsValueToChange settingsParam,
    required String value,
  }) async {
    final valueToWrite = constructWrite(
      deviceId: deviceId,
      parameter: WriteParameter.Settings,
      settings: oldSettings,
      slaveId: slaveId,
      settingsValueToChange: settingsParam,
      value: value,
    );

    return commitHelper(valueToWrite, deviceId);
  }
}
