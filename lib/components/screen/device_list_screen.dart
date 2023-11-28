import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultra_level_pro/ble/state.dart';
import 'package:ultra_level_pro/ble/turn_on_ble.dart';
import 'package:ultra_level_pro/components/widgets/home/ble_status_widget.dart';
import 'package:ultra_level_pro/components/widgets/home/device_list_widget.dart';
import 'package:ultra_level_pro/constants/constants.dart';

Future<bool> isPermissionAllowed(List<Permission> permissions) async {
  return Future.delayed(Duration.zero, () async {
    List<Permission> toGet = [];
    for (final permission in permissions) {
      final isGranted = await permission.isGranted;
      if (!isGranted) {
        toGet.add(permission);
      }
    }
    final requestGranted = await permissions.request();
    return requestGranted.values.every((e) => e == PermissionStatus.granted);
  });
}

Future<void> sleep() {
  return Future.delayed(const Duration(milliseconds: 500), () {});
}

Future<bool> checkAndRequestPermissions() async {
  bool isBluetoothConnectAllowed = await isPermissionAllowed([
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
    Permission.location
  ]);
  if (!isBluetoothConnectAllowed) return false;
  await sleep();

  await BleDeviceController.turnOn();
  return true;
}

class DeviceListScreen extends ConsumerStatefulWidget {
  const DeviceListScreen({super.key});

  @override
  ConsumerState<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends ConsumerState<DeviceListScreen> {
  Widget byBleStatus(WidgetRef ref, {required Widget child}) {
    final bleStatus = ref.watch(bleMonitorProvider);
    Widget loader = const Center(child: CircularProgressIndicator());

    return bleStatus.when(data: (status) {
      if (status == null) {
        return const Center(child: Text("Contact admin"));
      }
      if (status == BleStatus.ready) {
        return child;
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [BleStatusWidget(bleStatus: status)],
      );
    }, error: (err, stack) {
      return Text("Error: $err");
    }, loading: () {
      return loader;
    });
  }

  @override
  void initState() {
    super.initState();
    checkAndRequestPermissions().then((granted) {
      if (granted) {
        Future.delayed(Duration(milliseconds: 500), () {
          ref.read(bleScannerProvider).startScan([]);
        });
      }
    }).catchError((err) {
      debugPrint(
          'Something went wrong during granting permission ${err.toString()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(bleScannerStateProvider);
    final scanner = ref.watch(bleScannerProvider);
    final connectedDevice = ref.watch(bleConnectedDeviceProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Devices'),
        actions: [
          TextButton.icon(
            onPressed: () {
              if (scanner.isScanning) {
                scanner.stopScan();
              } else {
                scanner.startScan([]);
              }
            },
            icon: const Icon(Icons.refresh),
            label: scanner.isScanning
                ? const Text('Stop Scan')
                : const Text("Scan"),
          )
        ],
      ),
      body: byBleStatus(
        ref,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DeviceListWidget(
            devices: scannerState.value?.discoveredDevices ?? [],
            onTap: (device) async {
              scanner.stopScan();
              await ref.read(connectorProvider).connect(device.id);
              if (!context.mounted) return;
              connectedDevice.setDevice(device);
              Future.delayed(Duration.zero, () {
                GoRouter.of(context).push(getDeviceDetailsRoute(device.id));
              });
            },
          ),
        ),
      ),
    );
  }
}
