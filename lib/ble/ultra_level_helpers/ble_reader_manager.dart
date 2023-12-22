import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ultra_level_pro/ble/ble_device_connector.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_non_linear_state.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_ping_pong.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_state.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/helper.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/sleep.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/tank_type.dart';

void log(string) {
  debugPrint("${DateTime.now().toString()} $string");
}

class BleReaderManager extends ChangeNotifier {
  Timer? timer;
  BleState? state;
  bool loading = true;
  bool isTempPause = false;
  bool isPaused = false;
  String? error = null;
  String slaveId = '01';
  String deviceId;
  StreamSubscription<List<int>>? subscriber;
  FlutterReactiveBle ble;
  BleDeviceConnector connector;
  LastNPingPongMeta lastNPingPong;
  BleNonLinearState? nonLinearState;
  LastCompleter lastCompleter = LastCompleter();

  BleReaderManager({
    required this.deviceId,
    required this.ble,
    required this.connector,
    required this.lastNPingPong,
  });

  void _setBleState(BleState s) {
    state = s;
    isPaused = false;
    error = '';
    loading = false;
    notifyListeners();
  }

  void _setErrorState(dynamic err, String label) {
    log("setting error $label ${err.toString()}");

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
    error = str;
    loading = false;
    notifyListeners();
  }

  void setPaused() async {
    await lastCompleter.waitTillRead();
    log("paused");
    state = null;
    isPaused = true;
    error = '';
    loading = false;
    notifyListeners();
  }

  Future<void> setTempPause() async {
    await lastCompleter.waitTillRead();
    isTempPause = true;
    notifyListeners();
  }

  void _pollData() {
    log("started to poll");
    void pollData() async {
      await lastCompleter.waitTillRead();
      readFromBLE(deviceId, ble);
      Future.delayed(POLLING_DURATION, () async {
        await lastCompleter.waitTillRead();
        var isHalted = isPaused || isTempPause;
        if (isHalted) {
          return;
        }
        pollData();
      });
    }

    pollData();
    notifyListeners();
  }

  void setResume() {
    log("resuming polling ");
    isPaused = false;
    isTempPause = false;
    notifyListeners();
    _pollData();
    subscriber?.resume();
    error = null;
    notifyListeners();
  }

  Future<bool> disconnect() async {
    try {
      await lastCompleter.waitTillRead();
      isPaused = true;
      notifyListeners();

      log("Starting to disconnect");
      await subscriber?.cancel();
      await connector.disconnect(deviceId);
      return Future.value(true);
    } catch (err) {
      log("error in disconnecting device $err");
      return Future.value(false);
    }
  }

  Future<List<int>> _subscribeToCharacteristic(
      QualifiedCharacteristic txCh, PingPong pingPong, String label,
      [int waitSeconds = 6]) {
    void updateStatus(PingPongStatus status) {
      lastNPingPong.update(pingPong.request, status);
      notifyListeners();
    }

    Completer<List<int>> completer = Completer<List<int>>();
    var timer = Timer(Duration(seconds: waitSeconds), () {
      if (completer.isCompleted) {
        return;
      }
      updateStatus(PingPongStatus.failed);
      log("Ping: ${pingPong.request} timeout in receiving $label ");
      completer
          .completeError(ErrorDescription("Device failed to receive data"));
      subscriber?.cancel();
    });
    subscriber = ble.subscribeToCharacteristic(txCh).listen((data) {
      updateStatus(PingPongStatus.received);
      timer.cancel();
      log("Ping: ${pingPong.request} data received $label");
      if (completer.isCompleted) {
        return;
      }
      try {
        completer.complete(data);
        subscriber?.cancel();
      } catch (err) {
        log('Ping: ${pingPong.request} failed to complete $label'); // something the future the set to error by timeout and later we get the value
      }
    }, onError: (dynamic error) {
      updateStatus(PingPongStatus.failed);
      subscriber?.cancel();

      timer.cancel();
      log("Ping: ${pingPong.request} data error $label");
      completer.completeError(error);
    });

    return completer.future;
  }

  BleState? _onDataReceived(List<int> data) {
    final res = String.fromCharCodes(data);
    if (res.length < 20) return null;
    final state = BleState(data: res);
    _setBleState(state);
    return state;
  }

  void readNonLinear(PingPong pingPong) async {
    try {
      lastCompleter.createNewNonLinear();
      await sleep(1500);
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
      final writePromise = ble.writeCharacteristicWithResponse(
        rxCh,
        value: getReqCodeForNonLinear(slaveId),
      );

      Future.microtask(() {
        _subscribeToCharacteristic(txCh, pingPong, 'non linear').then((data) {
          final res = String.fromCharCodes(data);
          if (res.length < 20) return null;
          final state = BleNonLinearState(data: res);
          nonLinearState = state;
          notifyListeners();
          return data;
        }).catchError((err) {
          _setErrorState(err, 'non linear');
          return null;
        }).whenComplete(() {
          lastCompleter.updateNonLinear();
        });
      });

      log("Ping: ${pingPong.request} starting to read from ble non linear");
      await writePromise;
    } catch (err) {
      log('error reading for non linear $err');
      lastCompleter.updateNonLinear();
    }
  }

  void readFromBLE(String foundDeviceId, FlutterReactiveBle ble) async {
    try {
      lastCompleter.createNewData();
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

      Future.microtask(() {
        _subscribeToCharacteristic(txCh, pingPong, 'actual-data').then((val) {
          final data = _onDataReceived(val);
          log('tank type ${data?.tankType}');
          if (data?.tankType == TankType.nonLinear) {
            readNonLinear(pingPong);
            return data;
          }
          return data;
        }).catchError((err) {
          _setErrorState(err, 'actual-data');
          return null;
        }).whenComplete(() {
          lastCompleter.updateDataCompleted();
        });
        lastNPingPong.newRequest(pingPong);
      });

      notifyListeners();

      await writePromise;
      log("Ping: ${pingPong.request} starting to read from ble actual-data");
    } catch (err) {
      lastCompleter.updateDataCompleted();

      log("read from ble error $err");
      _setErrorState(err, 'actual-data');
      await disconnect();
    }

    // _setBleState(
    //   BleState(
    //     data:
    //         '01030040084908491B9E036F036F0B7220080B55DEAB0C58DC68000B000000000000000D0010005A000600FA0FA0000A03980014000000020BB803E803E803E800010008A4A6',
    //   ),
    // );
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

    _subscribeToCharacteristic(txCh, pingPong, 'slaveId').then((d) {
      _onDataReceived(d);
      completer.complete(true);
    }).catchError((error) {
      completer.complete(false);
    });
    log("Reading from ble");
    await ble.writeCharacteristicWithResponse(rxCh, value: getReqCode(slaveId));
    return completer.future;
  }

  void findSlaveId() async {
    for (int i = 255; i < 256; i++) {
      final _slaveId = intToHex(i).substring(2, 4);
      final res = await _checkSlaveId(_slaveId, ble);
      log("checking slave id $_slaveId: $res");
      if (res) {
        slaveId = _slaveId;
        setResume();
      }
    }
  }
}
