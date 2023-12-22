import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ultra_level_pro/ble/state.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_ping_pong.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_reader_manager.dart';

part 'ble_reader_provider.g.dart';

@riverpod
BleReaderManager getBleState(GetBleStateRef ref, {required String deviceId}) {
  final provider = ref.read(bleProvider);
  final connector = ref.read(connectorProvider);
  final readerManager = BleReaderManager(
    deviceId: deviceId,
    ble: provider,
    connector: connector,
    lastNPingPong: LastNPingPongMeta(max: 5, pingPongs: []),
  );

  void notifySelf() {
    ref.notifyListeners();
  }

  readerManager.addListener(notifySelf);

  Timer(Duration.zero, () {
    readerManager.setResume();
  });

  ref.onCancel(() {
    readerManager.removeListener(notifySelf);
  });
  return readerManager;
}
