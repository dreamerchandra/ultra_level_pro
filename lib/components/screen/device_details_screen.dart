import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:ultra_level_pro/ble/ble_connected_device.dart';
import 'package:ultra_level_pro/ble/state.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_reader_manager.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_reader_provider.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_writter.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/settings.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/tank_type_changer.dart';
import 'package:ultra_level_pro/components/widgets/common/admin_widget.dart';
import 'package:ultra_level_pro/components/widgets/common/card_details.dart';
import 'package:ultra_level_pro/components/widgets/common/expansion_tile_widget.dart';
import 'package:ultra_level_pro/components/widgets/common/ping_pong_status.dart';
import 'package:ultra_level_pro/components/widgets/device_detail/admin_settings_widget.dart';
import 'package:ultra_level_pro/components/widgets/device_detail/device_settings_widget.dart';
import 'package:ultra_level_pro/components/widgets/device_detail/read_values_widget.dart';
import 'package:ultra_level_pro/components/widgets/device_detail/settings_widget.dart';
import 'package:ultra_level_pro/components/widgets/device_detail/tank_details_widget.dart';
import 'package:ultra_level_pro/constants/common.dart';

class DeviceDetailWidget extends ConsumerStatefulWidget {
  const DeviceDetailWidget({super.key, required this.deviceId});
  final String deviceId;
  @override
  DetailViewState createState() => DetailViewState();
}

class DetailViewState extends ConsumerState<DeviceDetailWidget> {
  bool isAdmin = false;

  final List<MyExpansionTileController> controllers = [
    MyExpansionTileController(),
    MyExpansionTileController(),
    MyExpansionTileController(),
  ];

  BleReaderManager get reader {
    return ref.read(getBleStateProvider(deviceId: widget.deviceId));
  }

  @override
  void initState() {
    controllers.forEach((parentController) {
      parentController.addEventListener((isOpen) {
        if (!isOpen) {
          return;
        }
        if (getDeviceType() == DeviceType.tablet) {
          return;
        }
        controllers.forEach((child) {
          if (child != parentController) {
            child.collapse();
          }
        });
      });
    });
    super.initState();
  }

  Future<bool> writeToDevice(WriteParameter parameter, String value) {
    reader.timer?.cancel();
    return BleWriter(ble: ref.read(bleProvider))
        .writeToDevice(
      deviceId: widget.deviceId,
      parameter: parameter,
      value: value,
      settings: reader.state!.settings,
      slaveId: reader.state!.slaveId,
    )
        .whenComplete(
      () {
        reader.setResume();
      },
    );
  }

  Future<bool> onTankTypeChange(TankTypeChanger changer) {
    reader.timer?.cancel();
    return changer
        .commitTankType(
      deviceId: widget.deviceId,
      settings: reader.state!.settings,
      slaveId: reader.state!.slaveId,
    )
        .whenComplete(
      () {
        reader.setResume();
      },
    );
  }

  Future<bool> onSettingsChange({
    required String value,
    required SettingsValueToChange settingsParam,
  }) {
    reader.timer?.cancel();
    return BleWriter(ble: ref.read(bleProvider))
        .writeSettingsToDevice(
      deviceId: widget.deviceId,
      oldSettings: reader.state!.settings,
      slaveId: reader.state!.slaveId,
      settingsParam: settingsParam,
      value: value,
    )
        .whenComplete(
      () {
        reader.setResume();
      },
    );
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
      final scannedDevice = scannerState.value?.discoveredDevices
          .firstWhere((element) => element.id == connectedDevice.id);
      return scannedDevice?.rssi ?? -110;
    }
    return connectedDevice?.rssi ?? -110;
  }

  Widget buildReadHeaders() {
    final connectedDevice = getConnectedDevice();
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(4),
      },
      children: [
        TableRow(children: [
          const Text(
            "Name",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          Text(
            "${connectedDevice?.name}",
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ]),
        TableRow(
          children: [
            const Text(
              "RSSI ",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                Text(
                  "${getRSSI()}dBm",
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          shape: BoxShape.rectangle,
                          color: getRSSI() < -100 ? Colors.white : Colors.amber,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          shape: BoxShape.rectangle,
                          color: getRSSI() < -86 && getRSSI() < -100
                              ? Colors.white
                              : Colors.amber,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          shape: BoxShape.rectangle,
                          color: getRSSI() < -85 ? Colors.white : Colors.amber,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 6),
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
        TableRow(
          children: [
            const Text(
              "MAC ID ",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            Text(
              "${connectedDevice?.id}",
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final reader = ref.watch(GetBleStateProvider(deviceId: widget.deviceId));
    final connectedDevice = getConnectedDevice();
    final width = getDeviceType() == DeviceType.phone
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.width / 2;
    if (reader.loading) return const Center(child: CircularProgressIndicator());
    return WillPopScope(
      onWillPop: () {
        Completer<bool> completer = Completer();
        showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async =>
                  false, // False will prevent and true will allow to dismiss
              child: AlertDialog(
                title: Text('Going Back?'),
                content: Text('Would you like to go back'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      completer.complete(false);
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await reader.disconnect();
                      Navigator.pop(context);
                      completer.complete(true);
                    },
                    child: Text('Go Back'),
                  ),
                ],
              ),
            );
          },
        ) as Future<bool>;
        return completer.future;
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          floatingActionButton: AdminWidget(
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
              }),
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Basic"),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Tanks"),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Settings"),
                ),
              ],
            ),
            centerTitle: true,
            leading: IconButton(
                onPressed: () async {
                  debugPrint("Going back");
                  await reader.disconnect();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back)),
            title: Text(connectedDevice?.name ?? 'Loading...'),
            actions: [
              PingPongStatusWidget(
                timer: reader.timer,
                lastNPingPong: reader.lastNPingPong,
              ),
              TextButton.icon(
                onPressed: () async {
                  if (reader.isRunning) {
                    reader.setPaused();
                  } else {
                    reader.setResume();
                  }
                },
                icon: reader.isRunning
                    ? const Icon(Icons.pause)
                    : const Icon(Icons.play_arrow),
                label: const Text(''),
              )
            ],
          ),
          body: reader.state == null
              ? const Center(
                  child: Text("Device is paused"),
                )
              : TabBarView(
                  children: [
                    CardDetails(
                      width: width,
                      state: reader.state,
                      header: buildReadHeaders(),
                      body: ReadValues(state: reader.state),
                      initialExpanded: true,
                    ),
                    SingleChildScrollView(
                      child: CardDetails(
                        width: width,
                        state: reader.state,
                        header: const Text(
                          "Tank Details",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        body: TankDetailsWidget(
                          onDone: writeToDevice,
                          state: reader.state,
                          ble: ref.read(bleProvider),
                          onTankTypeChange: onTankTypeChange,
                        ),
                        initialExpanded: true,
                      ),
                    ),
                    SingleChildScrollView(
                      child: StaggeredGrid.count(
                        crossAxisCount:
                            getDeviceType() == DeviceType.phone ? 1 : 2,
                        children: [
                          CardDetails(
                            width: width,
                            controller: controllers[0],
                            state: reader.state,
                            header: const Text(
                              "Settings",
                              style: TextStyle(
                                color: Colors.white,
                              ),
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
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            body: DeviceSettingsWidget(
                              onDone: onSettingsChange,
                              state: reader.state,
                            ),
                            initialExpanded:
                                getDeviceType() == DeviceType.tablet,
                          ),
                          if (isAdmin) ...[
                            CardDetails(
                              width: width,
                              controller: controllers[2],
                              state: reader.state,
                              header: const Text(
                                "Admin Panel",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              body: AdminSettingsWidget(
                                onSettingsChange: onSettingsChange,
                                onChange: writeToDevice,
                                state: reader.state,
                              ),
                              initialExpanded:
                                  getDeviceType() == DeviceType.tablet,
                            )
                          ]
                        ],
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
