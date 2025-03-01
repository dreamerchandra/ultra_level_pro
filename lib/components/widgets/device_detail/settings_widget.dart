import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_state.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/device_selection.dart';
import 'package:ultra_level_pro/components/widgets/common/common.dart';
import 'package:ultra_level_pro/components/widgets/common/input.dart';

class SettingsWidget extends ConsumerWidget {
  const SettingsWidget({super.key, required this.state, required this.onDone});

  final Future<bool> Function(WriteParameter parameter, String value) onDone;

  final BleState? state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceSelection = ref.watch(deviceSelectionProvider);
    final isMax = deviceSelection == UltraLevelDevice.ultraLevelMax;
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
            if (isMax) ...[
              TableRow(
                children: [
                  const Text("Sleep Data Periodic in Sec"),
                  Text(': ${state?.lph}'),
                  formItem(
                    Input(
                      hintText: "1-65,000",
                      onDone: onDone,
                      parameter: WriteParameter.Lph,
                    ),
                  ),
                ],
              ),
            ],
            tableGap(),
            TableRow(
              children: [
                Text(
                  isMax ? "Data Periodic Pump ON Sec" : "0% Voltage Trimming",
                ),
                Text(': ${state?.zeroPercentTrimmingPoint}'),
                formItem(
                  Input(
                    hintText: isMax ? "1-3600" : '0.100',
                    onDone: onDone,
                    parameter: WriteParameter.ZeroPercentTrimmingPoint,
                  ),
                ),
              ],
            ),
            tableGap(),
            TableRow(
              children: [
                Text(isMax ? "Power dbm (1-20)" : "100% Voltage Trimming"),
                Text(': ${state?.hundredPercentTrimmingPoint}'),
                formItem(
                  Input(
                    hintText: isMax ? "1-22" : "4.000",
                    onDone: onDone,
                    parameter: WriteParameter.HundredPercentTrimmingPoint,
                  ),
                ),
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
                ),
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
                ),
              ],
            ),
            tableGap(),
          ],
        ),
      ],
    );
  }
}
