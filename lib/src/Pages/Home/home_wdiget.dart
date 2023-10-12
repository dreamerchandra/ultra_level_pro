import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultra_level_pro/src/Pages/Home/ble_status_widget.dart';
import 'package:ultra_level_pro/src/Pages/Home/device_list_widget.dart';
import 'package:ultra_level_pro/src/ble/state.dart';
import 'package:ultra_level_pro/src/ble/turn_on_ble.dart';
import 'package:ultra_level_pro/src/router/AppRouteConstants.dart';

class HomeWidget extends ConsumerStatefulWidget {
  const HomeWidget({super.key});

  @override
  ConsumerState<HomeWidget> createState() => HomeWidgetState();
}

Future<bool> isPermissionAllowed(Permission permission) async {
  final isGranted = await permission.isGranted;
  if (isGranted) {
    return true;
  }
  final requestGranted = await permission.request();
  if (requestGranted.isGranted) {
    return true;
  }
  return false;
}

class HomeWidgetState extends ConsumerState<HomeWidget> {
  @override
  void initState() {
    super.initState();
    isPermissionAllowed(Permission.bluetoothConnect).then((value) {
      isPermissionAllowed(Permission.bluetoothScan).then((value) {
        isPermissionAllowed(Permission.location).then((value) {
          BleDeviceController().inFlutter().then((value) {});
        });
      });
    });
  }

  Widget byBleStatus(WidgetRef ref, {required Widget child}) {
    final bleStatus = ref.watch(bleMonitorProvider);
    Widget loader = const Center(child: CircularProgressIndicator());

    return Builder(builder: (context) {
      return bleStatus.when(data: (status) {
        if (status == null) {
          return const Center(child: Text("Contact admin"));
        }
        if (status == BleStatus.ready) {
          return child;
        }

        return BleStatusWidget(bleStatus: status);
      }, error: (err, stack) {
        return Text("Error: $err");
      }, loading: () {
        return loader;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(bleMonitorProvider, (pre, next) {
      if (next.value == BleStatus.ready) {
        ref.read(bleScannerProvider).startScan([]);
      }
    });
    final scannerState = ref.watch(bleScannerStateProvider);
    final scanner = ref.watch(bleScannerProvider);
    final connectedDevice = ref.read(bleConnectedDeviceProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Devices'),
        actions: [
          TextButton.icon(
            onPressed: () {
              scanner.startScan([]);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          )
        ],
      ),
      body: byBleStatus(ref,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DeviceListWidget(
              devices: scannerState.value?.discoveredDevices ?? [],
              onTap: (device) async {
                scanner.stopScan();
                await ref.read(bleConnectorProvider).connect(device.id);
                if (!context.mounted) return;
                connectedDevice.setDevice(device);
                GoRouter.of(context).push(getDeviceDetailsRoute(device.id));
              },
            ),
          )),
    );
  }
}
