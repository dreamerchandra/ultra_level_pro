import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultra_level_pro/src/Pages/Detail/Cards/read_values_widget.dart';
import 'package:ultra_level_pro/src/Pages/Detail/Cards/settings_widget.dart';
import 'package:ultra_level_pro/src/Pages/Detail/Cards/tank_details_widget.dart';
import 'package:ultra_level_pro/src/ble/ble_connected_device.dart';
import 'package:ultra_level_pro/src/ble/state.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/ble_reader.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/ble_writter.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/src/common.dart';
import 'package:ultra_level_pro/src/component/card_details.dart';
import 'package:ultra_level_pro/src/component/expansion_title.dart';

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

  void setBleState(BleState s) {
    setState(() {
      state = s;
      isRunning = true;
      error = '';
      loading = false;
    });
  }

  void setErrorState(String err) {
    setState(() {
      state = null;
      isRunning = false;
      error = err;
      loading = false;
    });
  }

  void setPaused() async {
    debugPrint("disconnect");
    // await ref.read(bleProvider).clearGattCache(widget.deviceId);
    // await ref.read(bleConnectorProvider).disconnect(widget.deviceId);
    timer.cancel();
    setState(() {
      state = null;
      isRunning = false;
      error = '';
      loading = false;
    });
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
    pollData();
    setState(() {
      isRunning = true;
      error = '';
    });
  }

  late StreamSubscription<List<int>> subscriber;
  final List<MyExpansionTileController> controllers = [
    MyExpansionTileController(),
    MyExpansionTileController(),
    MyExpansionTileController(),
  ];
  @override
  void initState() {
    state = null;
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

  @override
  dispose() {
    subscriber.cancel();
    timer.cancel();
    super.dispose();
  }

  void readFromBLE(String foundDeviceId, FlutterReactiveBle ble) async {
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
    await ble.writeCharacteristicWithResponse(rxCh, value: REQ_CODE);
    // setBleState(BleState(
    //     data:
    //         '01030040084908491B9E036F036F0B7220080B55DEAB0C58DC68000B000000000000000D0010005A000600FA0FA0000A03980014000000020BB803E803E803E8000100087900'));
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

  BleConnectedDevice? getConnectedDevice() {
    final connectedDevice = ref.watch(bleConnectedDeviceProvider);
    return connectedDevice;
  }

  Widget buildReadHeaders() {
    final connectedDevice = getConnectedDevice();
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(4),
      },
      children: [
        TableRow(
          children: [
            Text(
              "ULP ${connectedDevice?.rssi}",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            Text(
              ": ${connectedDevice?.name}",
              style: TextStyle(
                color: Colors.white,
              ),
            )
          ],
        ),
        TableRow(
          children: [
            Text(
              "ID ${connectedDevice?.id}",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            Text(
              ":UID ${connectedDevice?.name}",
              style: TextStyle(
                color: Colors.white,
              ),
            )
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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
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
      body: SingleChildScrollView(
        child: Wrap(
          children: [
            SizedBox(
              width: width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CardDetails(
                  controller: controllers[0],
                  state: state,
                  header: buildReadHeaders(),
                  body: ReadValues(state: state),
                  initialExpanded: true,
                ),
              ),
            ),
            SizedBox(
              width: width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CardDetails(
                  controller: controllers[1],
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
                  ),
                  initialExpanded: getDeviceType() == DeviceType.tablet,
                ),
              ),
            ),
            SizedBox(
              width: width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CardDetails(
                  controller: controllers[2],
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
                  initialExpanded: getDeviceType() == DeviceType.tablet,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
