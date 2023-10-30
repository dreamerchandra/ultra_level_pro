import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:ultra_level_pro/src/Pages/Detail/Cards/device_settings_widget.dart';
import 'package:ultra_level_pro/src/Pages/Detail/Cards/read_values_widget.dart';
import 'package:ultra_level_pro/src/Pages/Detail/Cards/settings_widget.dart';
import 'package:ultra_level_pro/src/Pages/Detail/Cards/tank_details_widget.dart';
import 'package:ultra_level_pro/src/ble/ble_connected_device.dart';
import 'package:ultra_level_pro/src/ble/state.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/ble_reader.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/ble_writter.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/settings.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/tank_type_changer.dart';
import 'package:ultra_level_pro/src/common.dart';
import 'package:ultra_level_pro/src/component/card_details.dart';
import 'package:ultra_level_pro/src/component/expansion_title.dart';
import 'package:ultra_level_pro/src/component/topt.dart';

class DetailWidget extends ConsumerStatefulWidget {
  const DetailWidget({super.key, required this.deviceId});
  final String deviceId;
  @override
  DetailViewState createState() => DetailViewState();
}

class DetailViewState extends ConsumerState<DetailWidget> {
  bool isAdmin = false;
  BleReader? _reader;
  late NotifierFamily notifierFamily =
      NotifierFamily(context: context, deviceId: widget.deviceId);

  final List<MyExpansionTileController> controllers = [
    MyExpansionTileController(),
    MyExpansionTileController(),
  ];
  @override
  void initState() {
    Timer(Duration.zero, () {
      _reader = ref.watch(bleReaderService(notifierFamily));
      _reader?.setResume();
    });

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
    final reader = ref.read(bleReaderService(notifierFamily));
    reader.timer.cancel();
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
    final reader = ref.read(bleReaderService(notifierFamily));
    reader.timer.cancel();
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
    final reader = ref.read(bleReaderService(notifierFamily));
    reader.timer.cancel();
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
          .firstWhere((element) => element.id == connectedDevice?.id);
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
    final reader = ref.watch(bleReaderService(notifierFamily));
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
              PingPongStatus(timer: reader.timer),
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
                          )
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

class PingPongStatus extends StatefulWidget {
  const PingPongStatus({
    super.key,
    required this.timer,
  });

  final Timer timer;

  @override
  State<PingPongStatus> createState() => _PingPongStatusState();
}

class _PingPongStatusState extends State<PingPongStatus> {
  int oldTick = 0;
  late Timer timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(POLLING_DURATION, (t) {
      setState(() {
        oldTick = widget.timer.tick;
      });
    });
  }

  @override
  void dispose() async {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(100)),
      padding: const EdgeInsets.all(4),
      child: Text('${widget.timer.tick}'),
    );
  }
}
