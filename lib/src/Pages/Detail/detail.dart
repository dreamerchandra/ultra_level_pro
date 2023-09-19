import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultra_level_pro/src/Pages/Detail/shapes.dart';
import 'package:ultra_level_pro/src/ble/state.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/ble_state.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/ble_writter.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/tank_type.dart';
import 'package:ultra_level_pro/src/component/card_details.dart';
import 'package:ultra_level_pro/src/component/input.dart';

class DetailWidget extends ConsumerStatefulWidget {
  const DetailWidget({super.key, required this.deviceId});
  final String deviceId;
  @override
  DetailViewState createState() => DetailViewState();
}

class DetailViewState extends ConsumerState<DetailWidget> {
  late Timer timer;
  late BleState? state;
  late bool loading;
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
    await ref.read(bleConnectorProvider).disconnect(widget.deviceId);
    timer.cancel();
    setState(() {
      state = null;
      isRunning = false;
      error = '';
      loading = false;
    });
  }

  void pollData() {
    // readFromBLE(widget.deviceId, ref.read(bleProvider));
    timer = Timer.periodic(POLLING_DURATION, (timer) {
      debugPrint("timer");
      readFromBLE(widget.deviceId, ref.read(bleProvider));
    });
  }

  void setResume() async {
    setState(() {
      loading = true;
    });
    // await ref.read(bleConnectorProvider).connect(widget.deviceId);
    pollData();
    setState(() {
      state = null;
      isRunning = true;
      error = '';
      loading = false;
    });
  }

  late StreamSubscription<List<int>> subscriber;

  @override
  void initState() {
    state = null;
    setResume();
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
      setBleState(BleState(data: res));
      debugPrint("data: $res");
    }, onError: (dynamic error) {
      debugPrint("error: $error");
    });
    await ble.writeCharacteristicWithResponse(rxCh, value: REQ_CODE);
    // setBleState(BleState(
    //     data:
    //         '01030040084908491B9E036F036F0B7220080B55DEAB0C58DC68000B000000000000000D0010005A000600FA0FA0000A03980014000000020BB803E803E803E8000100087900'));
  }

  Widget buildReadValues() {
    return Table(
      children: [
        TableRow(
          children: [
            Text("Level in Liter"),
            Text(': ${state?.levelInLiter} L')
          ],
        ),
        TableRow(
          children: [Text("Level in mm"), Text(': ${state?.levelInMm} mm')],
        ),
        TableRow(
          children: [
            Text("Level in Perc%"),
            Text(': ${state?.levelInPercent} %')
          ],
        ),
        TableRow(
          children: [
            Text("Alarm"),
            Wrap(
              children: state?.alarm
                      .map(
                        (e) => Chip(
                          label: Text(
                            e.name.split('_').join(' ').toLowerCase(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          visualDensity: VisualDensity.compact,
                          clipBehavior: Clip.antiAlias,
                        ),
                      )
                      .toList() ??
                  [],
            )
          ],
        ),
        TableRow(
          children: [Text("Version"), Text(": ${state?.version}")],
        ),
        TableRow(
          children: [
            Text("Pover supply V"),
            Text(": ${state?.powerSupplyVoltage} V")
          ],
        ),
        TableRow(
          children: [Text("Settings"), Text(": ${state?.settings}")],
        ),
      ],
    );
  }

  Widget formItem(Widget child) {
    return SizedBox(
      height: 22,
      child: child,
    );
  }

  TableRow tableGap() {
    return const TableRow(
      children: [
        SizedBox(
          height: 12,
        ),
        SizedBox(
          height: 12,
        ),
        SizedBox(
          height: 12,
        ),
      ],
    );
  }

  Future<bool> onDone(WriteParameter parameter, String value) {
    return BleWriter(ble: ref.read(bleProvider)).writeToDevice(
        deviceId: widget.deviceId, parameter: parameter, value: value);
  }

  final List<String> tankTypes = TankType.values.map((e) => e.name).toList();
  Widget buildTankDetails() {
    return Column(
      children: [
        horizontalCylinder(),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(2),
          },
          children: [
            TableRow(
              children: [
                Text("Tank type"),
                Text(': ${state?.tankType.name}'),
                formItem(
                  DropdownButton<String>(
                    style: TextStyle(color: Colors.black87),
                    underline: Container(),
                    value: state?.tankType.name ?? tankTypes[0],
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: tankTypes.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      debugPrint("newValue: $newValue");
                    },
                  ),
                )
              ],
            ),
            tableGap(),
            TableRow(
              children: [
                Text("Tank height"),
                Text(': ${state?.tankHeight} mm'),
                formItem(
                  Input(
                    hintText: "Tank height",
                    onDone: onDone,
                    parameter: WriteParameter.TankHeight,
                  ),
                )
              ],
            ),
            tableGap(),
            TableRow(
              children: [
                Text("Tank Lenght"),
                Text(': ${state?.tankLength} mm'),
                formItem(
                  Input(
                    hintText: "Tank Length",
                    onDone: onDone,
                    parameter: WriteParameter.TankLength,
                  ),
                )
              ],
            ),
            tableGap(),
            TableRow(
              children: [
                Text("Tank Diameter"),
                Text(": ${state?.tankWidth} mm"),
                formItem(
                  Input(
                    hintText: "Tank diameter",
                    onDone: onDone,
                    parameter: WriteParameter.TankWidth,
                  ),
                )
              ],
            ),
            tableGap(),
            TableRow(
              children: [
                Text("Low level Relay"),
                Text(": ${state?.lowLevelRelayInMm} mm"),
                formItem(
                  Input(
                    hintText: "Low level relay",
                    onDone: onDone,
                    parameter: WriteParameter.LowLevelRelayInMm,
                  ),
                )
              ],
            ),
            tableGap(),
            TableRow(
              children: [
                Text("High level Relay"),
                Text(": ${state?.highLevelRelayInPercent} %"),
                formItem(
                  Input(
                    hintText: "High level relay",
                    onDone: onDone,
                    parameter: WriteParameter.HighLevelRelayInPercent,
                  ),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget buildReadHeaders() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(4),
      },
      children: const [
        TableRow(
          children: [Text("ULP"), Text(":testing device")],
        ),
        TableRow(
          children: [Text("ID"), Text(":UID")],
        )
      ],
    );
  }

  Widget buildSettings() {
    return Column(
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(2),
          },
          children: [
            TableRow(
              children: [
                Text("Dammping"),
                Text(': ${state?.damping}'),
                formItem(
                  Input(
                    hintText: "Dammping",
                    onDone: onDone,
                    parameter: WriteParameter.Damping,
                  ),
                )
              ],
            ),
            tableGap(),
            TableRow(
              children: [
                Text("Calibirate"),
                Text(': ${state?.levelCalibrationOffset}'),
                formItem(
                  Input(
                      hintText: "Calibirate",
                      onDone: onDone,
                      parameter: WriteParameter.LevelCalibrationOffset),
                )
              ],
            ),
            tableGap(),
            TableRow(
              children: [
                Text("Sensor Offset"),
                Text(': ${state?.sensorOffset}'),
                formItem(
                  Input(
                    onDone: onDone,
                    parameter: WriteParameter.SensorOffset,
                    hintText: "Sensor Offset",
                  ),
                )
              ],
            ),
            tableGap(),
            TableRow(
              children: [
                Text("Slave Id"),
                Text(": ${state?.slaveId}"),
                formItem(
                  Input(
                    hintText: "Slave Id",
                    onDone: onDone,
                    parameter: WriteParameter.SlaveId,
                  ),
                )
              ],
            ),
            tableGap(),
            TableRow(
              children: [
                Text("Low level Relay"),
                Text(": ${state?.lowLevelRelayInMm} mm"),
                formItem(
                  Input(
                    hintText: "Low level relay",
                    onDone: onDone,
                    parameter: WriteParameter.LowLevelRelayInMm,
                  ),
                )
              ],
            ),
            tableGap(),
            TableRow(
              children: [
                Text("High level Relay"),
                Text(": ${state?.highLevelRelayInPercent} %"),
                formItem(
                  Input(
                    hintText: "High level relay",
                    onDone: onDone,
                    parameter: WriteParameter.HighLevelRelayInPercent,
                  ),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (state == null) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
        title: Text("Device name"),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CardDetails(
                state: state,
                header: buildReadHeaders(),
                body: buildReadValues(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CardDetails(
                state: state,
                header: const Text("Tank Details"),
                body: buildTankDetails(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CardDetails(
                state: state,
                header: const Text("Settings"),
                body: buildSettings(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
