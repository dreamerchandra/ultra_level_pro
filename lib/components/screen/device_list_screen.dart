import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultra_level_pro/ble/state.dart';
import 'package:ultra_level_pro/ble/turn_on_ble.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/device_selection.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/sleep.dart';
import 'package:ultra_level_pro/components/widgets/home/ble_status_widget.dart';
import 'package:ultra_level_pro/components/widgets/home/device_list_widget.dart';
import 'package:ultra_level_pro/constants/constants.dart';

String getLabel(UltraLevelDevice? devices) {
  switch (devices) {
    case UltraLevelDevice.ultraLevelPro:
      return 'ULTRALEVEL PRO';
    case UltraLevelDevice.ultraLevelMax:
      return 'ULTRALEVEL MAX';
    case UltraLevelDevice.smartStarter:
      return 'SMART STARTER';
    case UltraLevelDevice.ultraLevelDisplay:
      return 'ULTRALEVEL DISPLAY';
    default:
      return 'Select Device';
  }
}

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

Future<bool> checkAndRequestPermissions() async {
  bool isBluetoothConnectAllowed = await isPermissionAllowed([
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
    Permission.location,
  ]);
  if (!isBluetoothConnectAllowed) return false;
  await sleep(500);

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

    return bleStatus.when(
      data: (status) {
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
      },
      error: (err, stack) {
        return Text("Error: $err");
      },
      loading: () {
        return loader;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    checkAndRequestPermissions()
        .then((granted) {
          if (granted) {
            Future.delayed(Duration(milliseconds: 500), () {
              ref.read(bleScannerProvider).startScan([]);
            });
          }
        })
        .catchError((err) {
          debugPrint(
            'Something went wrong during granting permission ${err.toString()}',
          );
        });
  }

  String connectingDevice = '';

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(bleScannerStateProvider);
    final scanner = ref.watch(bleScannerProvider);
    final connectedDevice = ref.watch(bleConnectedDeviceProvider.notifier);
    final deviceSelection = ref.watch(deviceSelectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(getLabel(deviceSelection)),
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
            label:
                scanner.isScanning
                    ? const Text('Stop Scan')
                    : const Text("Scan"),
          ),
        ],
      ),
      body: byBleStatus(
        ref,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DeviceListWidget(
            devices: scannerState.value?.discoveredDevices ?? [],
            connectingDeviceId: connectingDevice,
            onTap: (device) async {
              setState(() {
                connectingDevice = device.id;
              });
              scanner.stopScan();
              await ref.read(connectorProvider).connect(device.id);
              if (!context.mounted) return;
              setState(() {
                connectingDevice = '';
              });
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
