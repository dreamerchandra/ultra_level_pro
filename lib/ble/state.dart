import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ultra_level_pro/ble/ble_connected_device.dart';
import 'package:ultra_level_pro/ble/ble_device_connector.dart';
import 'package:ultra_level_pro/ble/ble_device_interactor.dart';
import 'package:ultra_level_pro/ble/ble_logger.dart';
import 'package:ultra_level_pro/ble/ble_scanner.dart';
import 'package:ultra_level_pro/ble/ble_status_monitor.dart';

part 'state.g.dart';

final _ble = FlutterReactiveBle();
final _bleLogger = BleLogger(ble: _ble);
final _scanner = BleScanner(ble: _ble, logMessage: _bleLogger.addToLog);
final _monitor = BleStatusMonitor(_ble);
final _connector = BleDeviceConnector(
  ble: _ble,
  logMessage: _bleLogger.addToLog,
);

final _serviceDiscoverer = BleDeviceInteractor(
  bleDiscoverServices: (deviceId) async {
    await _ble.discoverAllServices(deviceId);
    return _ble.getDiscoveredServices(deviceId);
  },
  logMessage: _bleLogger.addToLog,
);

@Riverpod(keepAlive: true)
FlutterReactiveBle ble(BleRef ref) {
  return _ble;
}

final bleLoggerProvider = Provider((ref) => _bleLogger);
final bleScannerProvider = Provider((ref) => _scanner);
final bleMonitorProvider = StreamProvider<BleStatus?>((ref) {
  return _monitor.state;
});

@Riverpod(keepAlive: true)
BleDeviceConnector connector(ConnectorRef ref) {
  return _connector;
}

final bleServiceDiscovererProvider = Provider((ref) => _serviceDiscoverer);
final bleScannerStateProvider = StreamProvider<BleScannerState?>((ref) async* {
  await for (final message in _scanner.state) {
    yield message;
  }
});
final bleConnectedDeviceProvider =
    StateNotifierProvider<BleConnectedDeviceNotifier, BleConnectedDevice?>(
      (ref) => BleConnectedDeviceNotifier(),
    );
