import 'package:flutter/material.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_state.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/settings.dart';
import 'package:ultra_level_pro/components/widgets/common/common.dart';
import 'package:ultra_level_pro/components/widgets/common/input.dart';

class AdminSettingsWidget extends StatefulWidget {
  const AdminSettingsWidget({
    super.key,
    required this.state,
    required this.onSettingsChange,
    required this.onChange,
  });

  final Future<bool> Function({
    required String value,
    required SettingsValueToChange settingsParam,
  }) onSettingsChange;

  final Future<bool> Function(
    WriteParameter parameter,
    String value,
  ) onChange;

  final BleState? state;

  @override
  State<AdminSettingsWidget> createState() => _AdminSettingsWidgetState();
}

class _AdminSettingsWidgetState extends State<AdminSettingsWidget> {
  bool isMutation = false;

  void writeToDevice(String value,
      {SettingsValueToChange? settingsValueToChange,
      WriteParameter? parameter}) async {
    try {
      setState(() {
        isMutation = true;
      });
      if (parameter != null) {
        await widget.onChange(parameter, value);
      } else if (settingsValueToChange != null) {
        await widget.onSettingsChange(
          settingsParam: settingsValueToChange,
          value: value,
        );
      }
    } catch (e) {
      return Future.delayed(const Duration(microseconds: 500), () {
        setState(() {
          isMutation = false;
        });
      });
    }
  }

  onMMChange() {
    if (isMutation) return null;
    // return null;
    return (bool value) {
      writeToDevice(
        value ? '1' : '0',
        settingsValueToChange: SettingsValueToChange.isInMM,
      );
    };
  }

  Widget commonSwitch({
    required bool value,
  }) {
    return formItem(
      Switch(
        value: value,
        onChanged: onMMChange(),
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
                const Text("Calibration"),
                Text(': ${widget.state?.levelCalibrationOffset}'),
                formItem(
                  Input(
                    hintText: "9100",
                    onDone: (parameter, value) {
                      return widget.onChange(
                        parameter,
                        value,
                      );
                    },
                    parameter: WriteParameter.LevelCalibrationOffset,
                  ),
                )
              ],
            ),
            tableGap(),
            TableRow(
              children: [
                const Text("In mm/cm"),
                Text(
                    ': ${widget.state?.settings.isInMM == true ? 'In mm' : 'In cm'}'),
                commonSwitch(
                  value: widget.state?.settings.isInMM ?? false,
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
