import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ultra_level_pro/ble/ble_device_connector.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_ping_pong.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_state.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/helper.dart';

class BleReaderManager extends ChangeNotifier {
  Timer? timer;
  BleState? state;
  bool loading = true;
  bool isRunning = false;
  String? error = null;
  String slaveId = '01';
  String deviceId;
  StreamSubscription<List<int>>? subscriber;
  FlutterReactiveBle ble;
  BleDeviceConnector connector;
  LastNPingPongMeta lastNPingPong;

  BleReaderManager({
    required this.deviceId,
    required this.ble,
    required this.connector,
    required this.lastNPingPong,
  });

  void _setBleState(BleState s) {
    state = s;
    isRunning = true;
    error = '';
    loading = false;
    notifyListeners();
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
    error = str;
    loading = false;
    notifyListeners();
  }

  void setPaused() {
    timer?.cancel();
    debugPrint("paused");
    state = null;
    isRunning = false;
    error = '';
    loading = false;
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
    notifyListeners();
  }

  void setResume() {
    debugPrint("resuming polling ");
    _pollData();
    isRunning = true;
    error = null;
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
    return Future.microtask(() {
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
        try {
          completer.complete(data);
        } catch (err) {
          debugPrint(
              'Continue to do operation.'); // something the future the set to error by timeout and later we get the value
        }
      });
      subscriber!.onError((dynamic error) {
        updateStatus(PingPongStatus.failed);
        timer.cancel();
        debugPrint("data not found");
        completer.completeError(error);
      });

      return completer.future;
    });
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
      notifyListeners();

      await writePromise;
      debugPrint("Reading from ble");
    } catch (err) {
      debugPrint("read from ble error $err");
      _setErrorState(err);
      await disconnect();
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
    notifyListeners();
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
      debugPrint("checking slave id $_slaveId: $res");
      if (res) {
        slaveId = _slaveId;
        setResume();
      }
    }
  }
}
