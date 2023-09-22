import 'package:flutter/material.dart';
import 'package:ultra_level_pro/src/Pages/Detail/Cards/common.dart';
import 'package:ultra_level_pro/src/Pages/Detail/shapes.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/ble_reader.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/tank_type.dart';
import 'package:ultra_level_pro/src/component/input.dart';

class TankDetailsWidget extends StatelessWidget {
  TankDetailsWidget({
    super.key,
    required this.state,
    required this.onDone,
  });

  final Future<bool> Function(WriteParameter parameter, String value) onDone;

  final List<String> tankTypes = TankType.values.map((e) => e.name).toList();

  final BleState? state;

  @override
  Widget build(BuildContext context) {
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
}
