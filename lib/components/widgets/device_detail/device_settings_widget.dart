import 'package:flutter/material.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_state.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/settings.dart';
import 'package:ultra_level_pro/components/widgets/common/common.dart';

class DeviceSettingsWidget extends StatefulWidget {
  const DeviceSettingsWidget({
    super.key,
    required this.state,
    required this.onDone,
  });

  final Future<bool> Function({
    required String value,
    required SettingsValueToChange settingsParam,
  }) onDone;

  final BleState? state;

  @override
  State<DeviceSettingsWidget> createState() => _DeviceSettingsWidgetState();
}

class _DeviceSettingsWidgetState extends State<DeviceSettingsWidget> {
  bool isMutation = false;

  void writeToDevice({
    required String value,
    required SettingsValueToChange settingsParam,
  }) async {
    try {
      setState(() {
        isMutation = true;
      });
      await widget.onDone(settingsParam: settingsParam, value: value);
    } catch (e) {
      return Future.delayed(const Duration(microseconds: 500), () {
        setState(() {
          isMutation = false;
        });
      });
    }
  }

  onChanged() {
    if (isMutation) return null;
    // return null;
    return (bool value) {
      writeToDevice(
        value: value ? '1' : '0',
        settingsParam: SettingsValueToChange.isInMM,
      );
    };
  }

  Widget commonSwitch({
    required bool value,
  }) {
    return formItem(
      Switch(
        value: value,
        onChanged: onChanged(),
      ),
    );
  }

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
                const Text("Temperature Sensor Enable"),
                Text(
                    ': ${widget.state?.settings.isTemperatureSensorEnabled == true ? 'Enabled' : 'Disabled'}'),
                commonSwitch(
                  value: widget.state?.settings.isTemperatureSensorEnabled ??
                      false,
                )
              ],
            ),
            tableGap(),
            TableRow(
              children: [
                const Text("DAC 0-4V"),
                Text(
                    ': ${widget.state?.settings.dac == true ? 'Enabled' : 'Disabled'}'),
                commonSwitch(
                  value: widget.state?.settings.dac ?? false,
                )
              ],
            ),
            tableGap(),
            TableRow(
              children: [
                const Text("RS485"),
                Text(
                    ": ${widget.state?.settings.rs465 == true ? 'Enabled' : 'Disabled'}"),
                commonSwitch(
                  value: widget.state?.settings.rs465 ?? false,
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
