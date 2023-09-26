import 'package:flutter/material.dart';
import 'package:ultra_level_pro/src/Pages/Detail/Cards/common.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/ble_reader.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/constant.dart';

class DeviceSettingsWidget extends StatelessWidget {
  const DeviceSettingsWidget({
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
                const Text("In mm/cm"),
                Text(': ${state?.settings.isInMM == true ? 'In mm' : 'In cm'}'),
                formItem(
                  Switch(
                    value: state?.settings.isInMM ?? false,
                    onChanged: (bool value) {
                      debugPrint("test");
                    },
                  ),
                )
              ],
            ),
            tableGap(),
            TableRow(
              children: [
                const Text("Temperature Sensor Enable"),
                Text(
                    ': ${state?.settings.isTemperatureSensorEnabled == true ? 'Enabled' : 'Disabled'}'),
                formItem(
                  Switch(
                    value: state?.settings.isTemperatureSensorEnabled ?? false,
                    onChanged: (bool value) {
                      debugPrint("test");
                    },
                  ),
                )
              ],
            ),
            tableGap(),
            TableRow(
              children: [
                const Text("DAC 0-4V"),
                Text(
                    ': ${state?.settings.dac == true ? 'Enabled' : 'Disabled'}'),
                formItem(
                  Switch(
                    value: state?.settings.dac ?? false,
                    onChanged: (bool value) {
                      debugPrint("test");
                    },
                  ),
                )
              ],
            ),
            tableGap(),
            TableRow(
              children: [
                const Text("RS485"),
                Text(
                    ": ${state?.settings.rs465 == true ? 'Enabled' : 'Disabled'}"),
                formItem(
                  Switch(
                    value: state?.settings.rs465 ?? false,
                    onChanged: (bool value) {
                      debugPrint("test");
                    },
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
