import 'package:flutter/material.dart';
import 'package:ultra_level_pro/src/Pages/Detail/Cards/common.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/ble_reader.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/src/component/input.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({
    super.key,
    required this.state,
    required this.onDone,
  });

  final Future<bool> Function(WriteParameter parameter, String value) onDone;

  final BleState? state;

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
      ],
    );
  }
}
