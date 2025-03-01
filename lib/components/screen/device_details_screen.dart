import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:ultra_level_pro/ble/ble_connected_device.dart';
import 'package:ultra_level_pro/ble/state.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_reader_manager.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_reader_provider.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_state.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_writter.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/settings.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/non_linear_ble_writer.dart';
import 'package:ultra_level_pro/components/alert.dart';
import 'package:ultra_level_pro/components/widgets/common/admin_widget.dart';
import 'package:ultra_level_pro/components/widgets/common/card_details.dart';
import 'package:ultra_level_pro/components/widgets/common/expansion_tile_widget.dart';
import 'package:ultra_level_pro/components/widgets/common/ping_pong_status.dart';
import 'package:ultra_level_pro/components/widgets/common/rssid.dart';
import 'package:ultra_level_pro/components/widgets/device_detail/admin_settings_widget.dart';
import 'package:ultra_level_pro/components/widgets/device_detail/device_settings_widget.dart';
import 'package:ultra_level_pro/components/widgets/device_detail/read_values_widget.dart';
import 'package:ultra_level_pro/components/widgets/device_detail/settings_widget.dart';
import 'package:ultra_level_pro/components/widgets/device_detail/tank_details_widget.dart';
import 'package:ultra_level_pro/constants/common.dart';

String insertColon(String input) {
  StringBuffer buffer = StringBuffer();
  for (int i = 0; i < input.length; i += 2) {
    buffer.write(input.substring(i, i + 2));
    if (i + 2 < input.length) {
      buffer.write(':');
    }
  }
  return buffer.toString();
}

class DeviceDetailWidget extends ConsumerStatefulWidget {
  const DeviceDetailWidget({super.key, required this.deviceId});
  final String deviceId;
  @override
  DetailViewState createState() => DetailViewState();
}

class DetailViewState extends ConsumerState<DeviceDetailWidget>
    with SingleTickerProviderStateMixin {
  bool isAdmin = false;
  late TabController tabController = TabController(length: 3, vsync: this);

  final List<MyExpansionTileController> controllers = [
    MyExpansionTileController(),
    MyExpansionTileController(),
    MyExpansionTileController(),
  ];

  BleReaderManager get reader {
    return ref.read(getBleStateProvider(deviceId: widget.deviceId));
  }

  void safeCollapse(MyExpansionTileController controller) {
    try {
      controller.collapse();
    } catch (err) {
      debugPrint("Error in safe collapse $err");
    }
  }

  @override
  void initState() {
    super.initState();
    for (var parentController in controllers) {
      parentController.addEventListener((isOpen) {
        if (!isOpen) {
          return;
        }
        if (getDeviceType() == DeviceType.tablet) {
          return;
        }
        for (var child in controllers) {
          if (child != parentController) {
            safeCollapse(child);
          }
        }
      });
    }
    super.initState();
  }

  Future<bool> writeToDevice(WriteParameter parameter, String value) async {
    await reader.setTempPause();
    return BleWriter(ble: ref.read(bleProvider))
        .writeToDevice(
          deviceId: widget.deviceId,
          parameter: parameter,
          value: value,
          settings: reader.state!.settings,
          slaveId: reader.state!.slaveId,
        )
        .whenComplete(() {
          reader.setResume();
        });
  }

  Future<bool> onTankTypeChange(NonLinearBleWriter changer) async {
    await reader.setTempPause();
    return changer
        .commitTankType(
          deviceId: widget.deviceId,
          settings: reader.state!.settings,
          slaveId: reader.state!.slaveId,
        )
        .whenComplete(() {
          reader.setResume();
        });
  }

  Future<bool> onChangeNonLinearTankLength(
    NonLinearBleWriter changer,
    int length,
  ) async {
    await reader.setTempPause();
    return changer
        .commitNonLinearTankLength(
          deviceId: widget.deviceId,
          settings: reader.state!.settings,
          slaveId: reader.state!.slaveId,
          length: length,
        )
        .whenComplete(() {
          reader.setResume();
        });
  }

  Future<bool> onSettingsChange({
    required String value,
    required SettingsValueToChange settingsParam,
  }) async {
    await reader.setTempPause();
    return BleWriter(ble: ref.read(bleProvider))
        .writeSettingsToDevice(
          deviceId: widget.deviceId,
          oldSettings: reader.state!.settings,
          slaveId: reader.state!.slaveId,
          settingsParam: settingsParam,
          value: value,
        )
        .whenComplete(() {
          reader.setResume();
        });
  }

  BleConnectedDevice? getConnectedDevice() {
    try {
      final connectedDevice = ref.watch(bleConnectedDeviceProvider);
      return connectedDevice;
    } catch (err) {
      debugPrint("get connected device error $err");
      if (context.mounted) GoRouter.of(context).go('/');
      return null;
    }
  }

  int getRSSI() {
    final connectedDevice = getConnectedDevice();
    final scannerState = ref.watch(bleScannerStateProvider).asData;
    if (connectedDevice != null && scannerState != null) {
      final scannedDevice = scannerState.value?.discoveredDevices.firstWhere(
        (element) => element.id == connectedDevice.id,
      );
      return scannedDevice?.rssi ?? -110;
    }
    return connectedDevice?.rssi ?? -110;
  }

  Widget buildReadHeaders(BleState? state) {
    final connectedDevice = getConnectedDevice();
    return Table(
      columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(4)},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            const Text("Name", style: TextStyle(color: Colors.white)),
            Text(
              "${connectedDevice?.name}",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        TableRow(
          children: [
            const Text("RSSI ", style: TextStyle(color: Colors.white)),
            Rssid(rssid: getRSSI(), textColor: Colors.white),
          ],
        ),
        TableRow(
          children: [
            const Text("MAC ID ", style: TextStyle(color: Colors.white)),
            Text(
              "${state != null ? insertColon(state.macAddress) : connectedDevice?.id}",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final reader = ref.watch(GetBleStateProvider(deviceId: widget.deviceId));
    final connectedDevice = getConnectedDevice();
    final width =
        getDeviceType() == DeviceType.phone
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.width / 2;
    if (reader.loading) return const Center(child: CircularProgressIndicator());
    if (reader.state == null) {
      return const Center(child: Text("Device is Paused"));
    }
    return WillPopScope(
      onWillPop: () {
        Completer<bool> completer = Completer();
        showAlertDialog(
          onOk: () async {
            await reader.disconnect();
            completer.complete(true);
          },
          onCancel: () {
            completer.complete(false);
          },
          context: context,
        );
        return completer.future;
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          floatingActionButton:
              tabController.index == 2
                  ? AdminWidget(
                    isAdmin: isAdmin,
                    setIsAdmin: (bool _isAdmin) {
                      if (_isAdmin) {
                        Timer(const Duration(minutes: 10), () {
                          setState(() {
                            isAdmin = false;
                          });
                        });
                      }
                      setState(() {
                        isAdmin = _isAdmin;
                      });
                    },
                  )
                  : null,
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            bottom: TabBar(
              controller: tabController,
              tabs: const [
                Padding(padding: EdgeInsets.all(8.0), child: Text("Basic")),
                Padding(padding: EdgeInsets.all(8.0), child: Text("Tanks")),
                Padding(padding: EdgeInsets.all(8.0), child: Text("Settings")),
              ],
            ),
            centerTitle: true,
            leading: IconButton(
              onPressed: () async {
                debugPrint("Going back");
                await reader.disconnect();
                if (context.mounted && Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.arrow_back),
            ),
            title: Text(connectedDevice?.name ?? 'Loading...'),
            actions: [
              PingPongStatusWidget(
                isPaused: reader.isPaused || reader.isTempPause,
                lastNPingPong: reader.lastNPingPong,
              ),
              TextButton.icon(
                onPressed: () async {
                  if (reader.isPaused) {
                    reader.setResume();
                  } else {
                    reader.setPaused();
                  }
                },
                icon:
                    reader.isPaused
                        ? const Icon(Icons.play_arrow)
                        : const Icon(Icons.pause),
                label: const Text(''),
              ),
            ],
          ),
          body: TabBarView(
            controller: tabController,
            children: [
              CardDetails(
                width: width,
                state: reader.state,
                header: buildReadHeaders(reader.state),
                body: ReadValues(state: reader.state),
                initialExpanded: true,
              ),
              SingleChildScrollView(
                child: CardDetails(
                  width: width,
                  state: reader.state,
                  header: const Text(
                    "Tank Details",
                    style: TextStyle(color: Colors.white),
                  ),
                  body: TankDetailsWidget(
                    onDone: writeToDevice,
                    state: reader.state,
                    ble: ref.read(bleProvider),
                    onTankTypeChange: onTankTypeChange,
                    onChangeNonLinearTankLength: onChangeNonLinearTankLength,
                    nonLinearState: reader.nonLinearState,
                    pauseTimer: () {
                      reader.setTempPause();
                    },
                    resumeTimer: () {
                      reader.setResume();
                    },
                  ),
                  initialExpanded: true,
                ),
              ),
              SingleChildScrollView(
                child: StaggeredGrid.count(
                  crossAxisCount: getDeviceType() == DeviceType.phone ? 1 : 2,
                  children: [
                    CardDetails(
                      width: width,
                      controller: controllers[0],
                      state: reader.state,
                      header: const Text(
                        "Settings",
                        style: TextStyle(color: Colors.white),
                      ),
                      body: SettingsWidget(
                        onDone: writeToDevice,
                        state: reader.state,
                      ),
                      initialExpanded: true,
                    ),
                    CardDetails(
                      width: width,
                      controller: controllers[1],
                      state: reader.state,
                      header: const Text(
                        "Device Settings",
                        style: TextStyle(color: Colors.white),
                      ),
                      body: DeviceSettingsWidget(
                        onDone: onSettingsChange,
                        state: reader.state,
                      ),
                      initialExpanded: getDeviceType() == DeviceType.tablet,
                    ),
                    if (isAdmin) ...[
                      CardDetails(
                        width: width,
                        controller: controllers[2],
                        state: reader.state,
                        header: const Text(
                          "Admin Panel",
                          style: TextStyle(color: Colors.white),
                        ),
                        body: AdminSettingsWidget(
                          onSettingsChange: onSettingsChange,
                          onChange: writeToDevice,
                          state: reader.state,
                        ),
                        initialExpanded: getDeviceType() == DeviceType.tablet,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
