import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ultra_level_pro/src/ble/ble_device_connector.dart';
import 'package:ultra_level_pro/src/ble/state.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/alarm.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/baud_rate.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/helper.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/settings.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/tank_type.dart';
import 'package:ultra_level_pro/src/helper/lru_array.dart';

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
  late double levelCalibrationOffset;
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
    levelCalibrationOffset = hexToInt(data.substring(i, i += 4)) / 1000;
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
  Timer? timer;
  BleState? state;
  bool loading = true;
  bool isRunning = false;
  String? error = null;
  String slaveId = '01';
  BuildContext context;
  String deviceId;
  StreamSubscription<List<int>>? subscriber;
  FlutterReactiveBle ble;
  BleDeviceConnector connector;
  LastNPingPong lastNPingPong;

  BleReader({
    required this.context,
    required this.deviceId,
    required this.ble,
    required this.connector,
    required this.lastNPingPong,
  });

  void _setBleState(BleState s) {
    if (context.mounted) {
      state = s;
      isRunning = true;
      error = '';
      loading = false;
      notifyListeners();
    }
  }

  void _setErrorState(dynamic err) {
    debugPrint("setting error ${err.toString()}");

    String str = '';
    if (err is String) {
      str = err;
    }
    if (err is ErrorDescription) {
      str = err.toDescription();
    }
    if (err is PlatformException) {
      str = err.message is String ? err.message! : err.toString();
    }
    if (context.mounted) {
      error = str;
      loading = false;
      notifyListeners();
    }
  }

  void setPaused() {
    timer?.cancel();
    debugPrint("paused");
    if (context.mounted) {
      state = null;
      isRunning = false;
      error = '';
      loading = false;
    }
    notifyListeners();
  }

  void _pollData() {
    debugPrint("started to poll");
    Timer(const Duration(seconds: 1), () {
      readFromBLE(deviceId, ble);
    });
    timer = Timer.periodic(POLLING_DURATION, (timer) {
      readFromBLE(deviceId, ble);
    });
  }

  void setResume() {
    debugPrint("resuming polling ");
    _pollData();
    if (context.mounted) {
      isRunning = true;
      error = '';
      notifyListeners();
    }
  }

  Future<bool> disconnect() async {
    try {
      timer?.cancel();
      await subscriber?.cancel();
      await connector.disconnect(deviceId);
      return Future.value(true);
    } catch (err) {
      debugPrint("error in disconnecting device $err");
      return Future.value(false);
    }
  }

  Future<List<int>> _subscribeToCharacteristic(
      QualifiedCharacteristic txCh, PingPong pingPong,
      [int waitSeconds = 4]) {
    void updateStatus(PingPongStatus status) {
      lastNPingPong.update(pingPong.request, status);
      notifyListeners();
    }

    debugPrint("subscriber present ${subscriber != null}");

    subscriber ??= ble.subscribeToCharacteristic(txCh).listen((event) {});
    if (subscriber == null) {
      throw Error();
    }
    Completer<List<int>> completer = Completer<List<int>>();
    var timer = Timer(Duration(seconds: waitSeconds), () {
      if (completer.isCompleted) {
        return;
      }
      updateStatus(PingPongStatus.failed);
      debugPrint("data failed to  receive data");
      completer
          .completeError(ErrorDescription("Device failed to receive data"));
    });
    subscriber!.onData((data) {
      updateStatus(PingPongStatus.received);
      timer.cancel();
      debugPrint("data retrieved");
      completer.complete(data);
    });
    subscriber!.onError((dynamic error) {
      updateStatus(PingPongStatus.failed);
      timer.cancel();
      debugPrint("data not found");
      completer.completeError(error);
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
      final writePromise =
          ble.writeCharacteristicWithResponse(rxCh, value: getReqCode(slaveId));
      PingPong pingPong = PingPong(
        status: PingPongStatus.requested,
        request: Random().nextInt(1000),
      );

      _subscribeToCharacteristic(txCh, pingPong)
          .then(_onDataReceived)
          .catchError((err) {
        _setErrorState(err);
      });
      lastNPingPong.newRequest(pingPong);

      await writePromise;
      debugPrint("Reading from ble");
    } catch (err) {
      debugPrint("read from ble error $err");
      _setErrorState(err);
      if (context.mounted) {
        await disconnect();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Something went wrong"),
        ));
        GoRouter.of(context).go('/');
      }
    }

    // setBleState(
    //   BleState(
    //     data:
    //         '01030040084908491B9E036F036F0B7220080B55DEAB0C58DC68000B000000000000000D0010005A000600FA0FA0000A03980014000000020BB803E803E803E8000100087900',
    //   ),
    // );
  }

  void pausePolling() {
    timer?.cancel();
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
    PingPong pingPong = PingPong(
      status: PingPongStatus.requested,
      request: Random().nextInt(1000),
    );

    _subscribeToCharacteristic(txCh, pingPong).then((d) {
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

class NotifierFamily {
  String deviceId;
  BuildContext context;
  NotifierFamily({required this.context, required this.deviceId});
}

final lastNPingPongProvider =
    StateNotifierProvider<LastNPingPong, List<PingPong>>(
        (ref) => LastNPingPong(max: 5));

final bleReaderService =
    ChangeNotifierProvider.family<BleReader, NotifierFamily>((ref, params) {
  final provider = ref.read(bleProvider);
  final connector = ref.read(bleConnectorProvider);
  final lastNPingPong = ref.read(lastNPingPongProvider.notifier);
  return BleReader(
    context: params.context,
    deviceId: params.deviceId,
    ble: provider,
    connector: connector,
    lastNPingPong: lastNPingPong,
  );
});
