import 'package:flutter/material.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_state.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/components/widgets/common/common.dart';
import 'package:ultra_level_pro/components/widgets/common/input.dart';

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
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: [
                Text("Zero % Voltage Trimming"),
                Text(': ${state?.zeroPercentTrimmingPoint}'),
                formItem(
                  Input(
                    hintText: "0.100",
                    onDone: onDone,
                    parameter: WriteParameter.ZeroPercentTrimmingPoint,
                  ),
                )
              ],
            ),
            tableGap(),
            TableRow(
              children: [
                Text("100% Voltage Trimming"),
                Text(': ${state?.hundredPercentTrimmingPoint}'),
                formItem(
                  Input(
                      hintText: "4.000",
                      onDone: onDone,
                      parameter: WriteParameter.HundredPercentTrimmingPoint),
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
