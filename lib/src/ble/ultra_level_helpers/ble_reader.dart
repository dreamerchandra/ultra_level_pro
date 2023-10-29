import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/alarm.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/baud_rate.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/helper.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/settings.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/tank_type.dart';

class BleState {
  String data;
  late int levelInLiter;
  late int levelInMm;
  late double levelInPercent;
  late int secondLevelInLiter;
  late int secondLevelInMm;
  late double secondLevelInPercent;
  late List<AlarmType> alarm;
  late double adcVoltage;
  late String macAddress;
  late String version;
  late double powerSupplyVoltage;
  late double temperature1;
  late double temperature2;
  late Settings settings;
  late int lowLevelRelayInMm;
  late double highLevelRelayInPercent;
  late int lph;
  late double zeroPercentTrimmingPoint;
  late double hundredPercentTrimmingPoint;
  late int damping;
  late int levelCalibrationOffset;
  late int sensorOffset;
  late int tankOffset;
  late TankType tankType;
  late int tankHeight;
  late int tankWidth;
  late int tankLength;
  late int tankDiameter;
  late String slaveId;
  late int baudRate;

  BleState({required this.data}) {
    if (!isCRCSame()) throw Exception("CRC is not same");
    computeValues();
  }

  dynamic getValueByWrite(WriteParameter parameter) {
    switch (parameter) {
      case WriteParameter.BaudRate:
        return baudRate;
      case WriteParameter.Damping:
        return damping;
      case WriteParameter.HighLevelRelayInPercent:
        return highLevelRelayInPercent;
      case WriteParameter.LevelCalibrationOffset:
        return levelCalibrationOffset;
      case WriteParameter.LowLevelRelayInMm:
        return lowLevelRelayInMm;
      case WriteParameter.Lph:
        return lph;
      case WriteParameter.SensorOffset:
        return sensorOffset;
      case WriteParameter.TankOffset:
        return tankOffset;
      case WriteParameter.TankType:
        return tankType;
      case WriteParameter.TankHeight:
        return tankHeight;
      case WriteParameter.TankWidth:
        return tankWidth;
      case WriteParameter.TankLength:
        return tankLength;
      case WriteParameter.TankDiameter:
        return tankDiameter;
      case WriteParameter.ZeroPercentTrimmingPoint:
        return zeroPercentTrimmingPoint;
      case WriteParameter.HundredPercentTrimmingPoint:
        return hundredPercentTrimmingPoint;
      case WriteParameter.Settings:
        return settings;
      case WriteParameter.SlaveId:
        return slaveId;
    }
  }

  bool isCRCSame() {
    final crcFromDevice = data.substring(data.length - 4);
    final dataToBeComputed = data.substring(0, data.length - 4);
    debugPrint('crc: $crcFromDevice');
    debugPrint('crcData: $dataToBeComputed');
    // return crcFromDevice == calculateModbusCRC(dataToBeComputed);
    return true;
  }

  void computeValues() {
    int i = 8;
    levelInLiter = hexToInt(data.substring(i, i += 4));
    levelInMm = hexToInt(data.substring(i, i += 4));
    levelInPercent = hexToInt(data.substring(i, i += 4)) / 100;
    secondLevelInLiter = hexToInt(data.substring(i, i += 4));
    secondLevelInMm = hexToInt(data.substring(i, i += 4));
    secondLevelInPercent = hexToInt(data.substring(i, i += 4)) / 100;
    alarm = getAlarm(data.substring(i, i += 4));
    adcVoltage = hexToInt(data.substring(i, i += 4)) / 1000;
    macAddress = data.substring(i, i += 4 * 3);
    version = data.substring(i, i += 4);
    powerSupplyVoltage = hexToInt(data.substring(i, i += 4)) / 100;
    temperature1 = hexToInt(data.substring(i, i += 4)) / 100;
    temperature2 = hexToInt(data.substring(i, i += 4)) / 100;
    settings = Settings.getSettings(data.substring(i, i += 4));
    lowLevelRelayInMm = hexToInt(data.substring(i, i += 4));
    highLevelRelayInPercent = hexToInt(data.substring(i, i += 4)) / 100;
    lph = hexToInt(data.substring(i, i += 4));
    zeroPercentTrimmingPoint = hexToInt(data.substring(i, i += 4)) / 1000;
    hundredPercentTrimmingPoint = hexToInt(data.substring(i, i += 4)) / 1000;
    damping = hexToInt(data.substring(i, i += 4));
    levelCalibrationOffset = hexToInt(data.substring(i, i += 4));
    sensorOffset = hexToInt(data.substring(i, i += 4));
    tankOffset = hexToInt(data.substring(i, i += 4));
    tankType = getTankType(data.substring(i, i += 4));
    tankHeight = hexToInt(data.substring(i, i += 4));
    tankWidth = hexToInt(data.substring(i, i += 4));
    tankLength = hexToInt(data.substring(i, i += 4));
    tankDiameter = hexToInt(data.substring(i, i += 4));
    slaveId = data.substring(i, i += 4).substring(2, 4);
    baudRate = getBaudRate(data.substring(i, i += 4));
  }
}

class BleReader extends ChangeNotifier {
  late Timer timer;
  late BleState? state;
  late bool loading = true;
  late bool isRunning = false;
  late String error;
  late String slaveId = '01';
  BuildContext context;
  String deviceId;
  StreamSubscription<List<int>>? subscriber;
  FlutterReactiveBle ble;

  BleReader({required this.context, required this.deviceId, required this.ble});

  void _setBleState(BleState s) {
    if (context.mounted) {
      state = s;
      isRunning = true;
      error = '';
      loading = false;
      notifyListeners();
    }
  }

  void _setErrorState(String err) {
    if (context.mounted) {
      state = null;
      isRunning = false;
      error = err;
      loading = false;
      notifyListeners();
    }
  }

  void setPaused() {
    timer.cancel();
    if (context.mounted) {
      state = null;
      isRunning = false;
      error = '';
      loading = false;
    }
    notifyListeners();
  }

  void _pollData() {
    Timer.periodic(const Duration(seconds: 1), (t) {
      readFromBLE(deviceId, ble);
    });
    timer = Timer.periodic(POLLING_DURATION, (timer) {
      debugPrint("timer");
      readFromBLE(deviceId, ble);
    });
  }

  void setResume() {
    _pollData();
    if (context.mounted) {
      isRunning = true;
      error = '';
      notifyListeners();
    }
  }

  Future<List<int>> _subscribeToCharacteristic(QualifiedCharacteristic txCh,
      [int waitSeconds = 4]) {
    subscriber ??= ble.subscribeToCharacteristic(txCh).listen((event) {});
    if (subscriber == null) {
      throw Error();
    }
    Completer<List<int>> completer = Completer<List<int>>();
    bool dataReceived = false;
    subscriber!.onData((data) {
      dataReceived = true;
      completer.complete(data);
    });
    subscriber!.onError((dynamic error) {
      dataReceived = true;
      completer.completeError(error);
    });
    Timer(Duration(seconds: waitSeconds), () {
      if (!dataReceived) {
        completer
            .completeError(ErrorDescription("Device failed to receive data"));
      }
    });
    return completer.future;
  }

  void _onDataReceived(List<int> data) {
    final res = String.fromCharCodes(data);
    debugPrint("data: $data");
    debugPrint("res: $res");
    if (res.length < 20) return;
    _setBleState(BleState(data: res));
    debugPrint("data: $res");
  }

  void readFromBLE(String foundDeviceId, FlutterReactiveBle ble) async {
    try {
      final txCh = QualifiedCharacteristic(
        serviceId: UART_UUID,
        characteristicId: UART_TX,
        deviceId: deviceId,
      );

      final rxCh = QualifiedCharacteristic(
        serviceId: UART_UUID,
        characteristicId: UART_RX,
        deviceId: deviceId,
      );
      _subscribeToCharacteristic(txCh)
          .then(_onDataReceived)
          .catchError((err) => {_setErrorState(err)});
      debugPrint("Reading from ble");
      await ble.writeCharacteristicWithResponse(rxCh,
          value: getReqCode(slaveId));
    } catch (err) {
      debugPrint("read from ble error $err");
      _setErrorState(err.toString());
    }

    // setBleState(
    //   BleState(
    //     data:
    //         '01030040084908491B9E036F036F0B7220080B55DEAB0C58DC68000B000000000000000D0010005A000600FA0FA0000A03980014000000020BB803E803E803E8000100087900',
    //   ),
    // );
  }

  void pausePolling() {
    timer.cancel();
  }

  Future<bool> _checkSlaveId(String slaveId, FlutterReactiveBle ble) async {
    Completer<bool> completer = Completer<bool>();
    final txCh = QualifiedCharacteristic(
      serviceId: UART_UUID,
      characteristicId: UART_TX,
      deviceId: deviceId,
    );

    final rxCh = QualifiedCharacteristic(
      serviceId: UART_UUID,
      characteristicId: UART_RX,
      deviceId: deviceId,
    );

    _subscribeToCharacteristic(txCh, 4).then((d) {
      _onDataReceived(d);
      completer.complete(true);
    }).catchError((error) {
      completer.complete(false);
    });
    debugPrint("Reading from ble");
    await ble.writeCharacteristicWithResponse(rxCh, value: getReqCode(slaveId));
    return completer.future;
  }

  void findSlaveId() async {
    for (int i = 255; i < 256; i++) {
      final _slaveId = intToHex(i).substring(2, 4);
      final res = await _checkSlaveId(_slaveId, ble);
      if (!context.mounted) {
        return;
      }
      debugPrint("checking slave id $_slaveId: $res");
      if (res) {
        slaveId = _slaveId;
        setResume();
      }
    }
  }
}
