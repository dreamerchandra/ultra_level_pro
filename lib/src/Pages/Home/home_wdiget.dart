import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ultra_level_pro/src/Pages/Home/device_list_widget.dart';
import 'package:ultra_level_pro/src/ble/state.dart';
import 'package:ultra_level_pro/src/router/AppRouteConstants.dart';

// class HomeWidget extends ConsumerStatefulWidget {
//   const HomeWidget({Key? key}) : super(key: key);
//   @override
//   HomeViewState createState() => HomeViewState();
// }

class HomeWidget extends ConsumerWidget {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scannerState = ref.watch(bleScannerStateProvider);
    final scanner = ref.watch(bleScannerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Devices'),
        actions: [
          TextButton.icon(
            onPressed: () {
              scanner.startScan([]);
            },
            icon: const Icon(Icons.refresh),
            label: const Text(''),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DeviceListWidget(
          devices: scannerState.value?.discoveredDevices ?? [],
          onTap: (device) async {
            scanner.stopScan();
            await ref.read(bleConnectorProvider).connect(device.id);
            GoRouter.of(context).push(getDeviceDetailsRoute(device.id));
          },
        ),
      ),
    );
  }
}
