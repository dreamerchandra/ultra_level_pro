import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
    Timer timer = Timer(Duration(seconds: 3), () {
      if (completer.isCompleted) {
        return;
      }
      debugPrint("Writing failed due to timeout ");
      completer.completeError(ErrorDescription("Device failed to write data"));
    });
    final subscription = ble.subscribeToCharacteristic(txCh).listen((data) {
      final res = String.fromCharCodes(data);
      completer.complete(res);
    }, onError: (dynamic error) {
      completer.completeError(error);
    });
    completer.future.then((_) {
      subscription.cancel();
      timer.cancel();
    }, onError: (_) {
      subscription.cancel();
      timer.cancel();
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
        Fluttertoast.showToast(msg: 'Write successfull');
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
    Clipboard.setData(ClipboardData(text: "${valueToWrite.toUpperCase()}"));
    Fluttertoast.showToast(
      msg: "${valueToWrite.toUpperCase()}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
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
