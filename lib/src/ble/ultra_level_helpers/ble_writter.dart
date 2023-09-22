import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/baud_rate.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/ble_reader.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/helper.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/settings.dart';

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
    return desiredValue == actualValue;
  }

  String getValueToWrite({
    required String deviceId,
    required WriteParameter parameter,
    required String value,
    required Settings settings,
    required String slaveId,
    SettingsValueToChange? settingsValueToChange,
  }) {
    final writeAddress = ParameterToAddress[parameter];
    String result =
        '${slaveId}06$writeAddress'; // slaveId funCode writeAddress data crc
    String data = '';
    switch (parameter) {
      case WriteParameter.BaudRate:
        data = getBitByBaudRate(int.parse(value));
        break;
      case WriteParameter.Damping:
        data = intToHex(int.parse(value));
        break;
      case WriteParameter.Settings:
        if (settingsValueToChange == null) {
          break;
        }
        data = Settings.settingsToHexString(
            Settings.updateNewSettings(settings, settingsValueToChange));
        break;
      case WriteParameter.LowLevelRelayInMm:
        data = intToHex(int.parse(value));
        break;
      case WriteParameter.HighLevelRelayInPercent:
        data = intToHex(int.parse(value) * 100);
        break;
      case WriteParameter.Lph:
        data = intToHex(int.parse(value));
      case WriteParameter.ZeroPercentTrimmingPoint:
        data = intToHex(int.parse(value) * 1000);
      case WriteParameter.HundredPercentTrimmingPoint:
        data = intToHex(int.parse(value) * 1000);
      case WriteParameter.LevelCalibrationOffset:
        data = intToHex(int.parse(value));
      case WriteParameter.SensorOffset:
        data = intToHex(int.parse(value));
      case WriteParameter.TankOffset:
        data = intToHex(int.parse(value));
      case WriteParameter.TankType:
        data = value;
      case WriteParameter.TankHeight:
        data = intToHex(int.parse(value));
      case WriteParameter.TankWidth:
        data = intToHex(int.parse(value));
      case WriteParameter.TankLength:
        data = intToHex(int.parse(value));
      case WriteParameter.SlaveId:
        break;
      case WriteParameter.TankDiameter:
        data = intToHex(int.parse(value));
    }
    final crc = calculateModbusCRC((result + data));
    final valueToWrite = result + data + crc;
    return valueToWrite;
  }

  Future<bool> writeToDevice({
    required String deviceId,
    required WriteParameter parameter,
    required String value,
    required Settings settings,
    required String slaveId,
  }) async {
    final valueToWrite = getValueToWrite(
        deviceId: deviceId,
        parameter: parameter,
        settings: settings,
        slaveId: slaveId,
        value: value); // voltage, 251

    Completer<bool> completer = Completer<bool>();
    verifyEcho(String echoValue) {
      if (checkWriteIsOk(
        actualValue: echoValue.substring(0, valueToWrite.length),
        desiredValue: valueToWrite,
      )) {
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
