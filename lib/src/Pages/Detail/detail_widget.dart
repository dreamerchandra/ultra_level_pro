import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
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
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/helper.dart';
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
  late Timer timer;
  late BleState? state;
  late bool loading = true;
  late bool isRunning;
  late String error;
  late String slaveId = '01';
  bool isAdmin = false;

  void setBleState(BleState s) {
    if (context.mounted) {
      setState(() {
        state = s;
        isRunning = true;
        error = '';
        loading = false;
      });
    }
  }

  void setErrorState(String err) {
    if (context.mounted) {
      setState(() {
        state = null;
        isRunning = false;
        error = err;
        loading = false;
      });
    }
  }

  void setPaused() async {
    debugPrint("disconnect");
    // await ref.read(bleProvider).clearGattCache(widget.deviceId);
    // await ref.read(bleConnectorProvider).disconnect(widget.deviceId);
    timer.cancel();
    if (context.mounted) {
      setState(() {
        state = null;
        isRunning = false;
        error = '';
        loading = false;
      });
    }
  }

  void pollData() {
    readFromBLE(widget.deviceId, ref.read(bleProvider));
    timer = Timer.periodic(POLLING_DURATION, (timer) {
      debugPrint("timer");
      readFromBLE(widget.deviceId, ref.read(bleProvider));
    });
  }

  void setResume() async {
    // await ref.read(bleConnectorProvider).connect(widget.deviceId);
    if (context.mounted) {
      pollData();
      setState(() {
        isRunning = true;
        error = '';
      });
    }
  }

  late StreamSubscription<List<int>> subscriber;
  final List<MyExpansionTileController> controllers = [
    MyExpansionTileController(),
    MyExpansionTileController(),
  ];
  @override
  void initState() {
    state = null;
    // findSlaveId();
    setResume();

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

  Future<bool> checkSlaveId(String slaveId, FlutterReactiveBle ble) async {
    Completer<bool> completer = Completer<bool>();
    final txCh = QualifiedCharacteristic(
      serviceId: UART_UUID,
      characteristicId: UART_TX,
      deviceId: widget.deviceId,
    );

    final rxCh = QualifiedCharacteristic(
      serviceId: UART_UUID,
      characteristicId: UART_RX,
      deviceId: widget.deviceId,
    );

    subscriber = ble.subscribeToCharacteristic(txCh).listen((data) {
      final res = String.fromCharCodes(data);
      debugPrint("data: $data");
      debugPrint("res: $res");
      if (res.length < 20) return;
      setBleState(BleState(data: res));
      debugPrint("data: $res");
      completer.complete(true);
      subscriber.cancel();
    }, onError: (dynamic error) {
      debugPrint("error: $error");
    });
    debugPrint("Reading from ble");
    await ble.writeCharacteristicWithResponse(rxCh, value: getReqCode(slaveId));
    Future.delayed(const Duration(seconds: 2), () {
      completer.complete(false);
      subscriber.cancel();
    });
    return completer.future;
  }

  void findSlaveId() async {
    for (int i = 255; i < 256; i++) {
      final _slaveId = intToHex(i).substring(2, 4);
      final res = await checkSlaveId(_slaveId, ref.read(bleProvider));
      if (!context.mounted) {
        return;
      }
      debugPrint("checking slave id $_slaveId: $res");
      if (res) {
        setState(() {
          slaveId = _slaveId;
        });
        setResume();
      }
    }
  }

  @override
  Future<void> dispose() async {
    subscriber.cancel();
    timer.cancel();
    final connector = ref.read(bleConnectorProvider);
    final ble = ref.read(bleProvider);
    Future.delayed(Duration.zero, () async {
      await connector.disconnect(widget.deviceId);
      await ble.clearGattCache(widget.deviceId);
    });
    super.dispose();
  }

  void readFromBLE(String foundDeviceId, FlutterReactiveBle ble) async {
    try {
      final txCh = QualifiedCharacteristic(
        serviceId: UART_UUID,
        characteristicId: UART_TX,
        deviceId: widget.deviceId,
      );

      final rxCh = QualifiedCharacteristic(
        serviceId: UART_UUID,
        characteristicId: UART_RX,
        deviceId: widget.deviceId,
      );

      subscriber = ble.subscribeToCharacteristic(txCh).listen((data) {
        final res = String.fromCharCodes(data);
        debugPrint("data: $data");
        debugPrint("res: $res");
        if (res.length < 20) return;
        setBleState(BleState(data: res));
        debugPrint("data: $res");
      }, onError: (dynamic error) {
        debugPrint("error: $error");
      });
      debugPrint("Reading from ble");
      await ble.writeCharacteristicWithResponse(rxCh,
          value: getReqCode(slaveId));
    } catch (err) {
      debugPrint("read from ble error $err");
      if (context.mounted) {
        GoRouter.of(context).go('/');
      }
    }

    // setBleState(
    //   BleState(
    //     data:
    //         '01030040084908491B9E036F036F0B7220080B55DEAB0C58DC68000B000000000000000D0010005A000600FA0FA0000A03980014000000020BB803E803E803E8000100087900',
    //   ),
    // );
  }

  Future<bool> onDone(WriteParameter parameter, String value) {
    timer.cancel();
    return BleWriter(ble: ref.read(bleProvider))
        .writeToDevice(
      deviceId: widget.deviceId,
      parameter: parameter,
      value: value,
      settings: state!.settings,
      slaveId: state!.slaveId,
    )
        .whenComplete(
      () {
        setResume();
      },
    );
  }

  Future<bool> onTankTypeChange(TankTypeChanger changer) {
    timer.cancel();
    return changer
        .commitTankType(
      deviceId: widget.deviceId,
      settings: state!.settings,
      slaveId: state!.slaveId,
    )
        .whenComplete(
      () {
        setResume();
      },
    );
  }

  Future<bool> onSettingsChange({
    required String value,
    required SettingsValueToChange settingsParam,
  }) {
    timer.cancel();
    return BleWriter(ble: ref.read(bleProvider))
        .writeSettingsToDevice(
      deviceId: widget.deviceId,
      oldSettings: state!.settings,
      slaveId: state!.slaveId,
      settingsParam: settingsParam,
      value: value,
    )
        .whenComplete(
      () {
        setResume();
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
    }
  }

  int getRSSI() {
    final connectedDevice = this.getConnectedDevice();
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
                  child: Expanded(
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
                            color:
                                getRSSI() < -100 ? Colors.white : Colors.amber,
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
                            color:
                                getRSSI() < -85 ? Colors.white : Colors.amber,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 6),
                        ),
                      ],
                    ),
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
    final connectedDevice = getConnectedDevice();
    final width = getDeviceType() == DeviceType.phone
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.width / 2;
    if (loading) return const Center(child: CircularProgressIndicator());
    return DefaultTabController(
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
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back)),
          title: Text(connectedDevice?.name ?? 'Loading...'),
          actions: [
            TextButton.icon(
              onPressed: () async {
                if (isRunning) {
                  setPaused();
                } else {
                  setResume();
                }
              },
              icon: isRunning
                  ? const Icon(Icons.pause)
                  : const Icon(Icons.play_arrow),
              label: const Text(''),
            )
          ],
        ),
        body: state == null
            ? const Center(
                child: Text("Device is paused"),
              )
            : TabBarView(
                children: [
                  CardDetails(
                    width: width,
                    state: state,
                    header: buildReadHeaders(),
                    body: ReadValues(state: state),
                    initialExpanded: true,
                  ),
                  SingleChildScrollView(
                    child: CardDetails(
                      width: width,
                      state: state,
                      header: const Text(
                        "Tank Details",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      body: TankDetailsWidget(
                        onDone: onDone,
                        state: state,
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
                          state: state,
                          header: const Text(
                            "Settings",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          body: SettingsWidget(
                            onDone: onDone,
                            state: state,
                          ),
                          initialExpanded: true,
                        ),
                        CardDetails(
                          width: width,
                          controller: controllers[1],
                          state: state,
                          header: const Text(
                            "Device Settings",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          body: DeviceSettingsWidget(
                            onDone: onSettingsChange,
                            state: state,
                          ),
                          initialExpanded: getDeviceType() == DeviceType.tablet,
                        )
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
