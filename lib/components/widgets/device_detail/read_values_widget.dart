import 'package:flutter/material.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_state.dart';
import 'package:ultra_level_pro/components/widgets/common/common.dart';

const headerStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);
const bodyStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

class ReadValues extends StatelessWidget {
  const ReadValues({
    super.key,
    required this.state,
  });

  final BleState? state;

  @override
  Widget build(BuildContext context) {
    return Table(
      children: [
        TableRow(
          children: [
            Text(
              "Level in Liter",
              style: headerStyle,
            ),
            Text(
              ': ${state?.levelInLiter} ',
              style: bodyStyle,
            ),
          ],
        ),
        rowSpacer,
        TableRow(
          children: [
            Text(
              "Level in ${state!.settings.isInMM ? 'mm' : 'cm'}",
              style: headerStyle,
            ),
            Text(
              ': ${state?.levelInMm} ',
              style: bodyStyle,
            )
          ],
        ),
        rowSpacer,
        TableRow(
          children: [
            Text(
              "Level in Per %",
              style: headerStyle,
            ),
            Text(
              ': ${state?.levelInPercent} ',
              style: bodyStyle,
            )
          ],
        ),
        rowSpacer,
        TableRow(
          children: [
            const Text("2nd Level in Liter", style: headerStyle),
            Text(': ${state?.secondLevelInLiter} ', style: bodyStyle)
          ],
        ),
        rowSpacer,
        TableRow(
          children: [
            Text("2nd Level in ${state!.settings.isInMM ? 'mm' : 'cm'}",
                style: headerStyle),
            Text(': ${state?.secondLevelInMm} ', style: bodyStyle)
          ],
        ),
        rowSpacer,
        TableRow(
          children: [
            const Text("2nd Level in Per %", style: headerStyle),
            Text(': ${state?.secondLevelInPercent} ', style: bodyStyle)
          ],
        ),
        rowSpacer,
        TableRow(
          children: [
            const Text("DAC Voltage", style: headerStyle),
            Text(': ${state?.adcVoltage}', style: bodyStyle)
          ],
        ),
        rowSpacer,
        TableRow(
          children: [
            const Text("Temperature 1° C", style: headerStyle),
            Text(': ${state?.temperature1} C', style: bodyStyle)
          ],
        ),
        rowSpacer,
        TableRow(
          children: [
            const Text("Temperature 2° C", style: headerStyle),
            Text(': ${state?.temperature2} C', style: bodyStyle)
          ],
        ),
        rowSpacer,
        TableRow(
          children: [
            Text("Version", style: headerStyle),
            Text(": ${state?.version}", style: bodyStyle)
          ],
        ),
        rowSpacer,
        TableRow(
          children: [
            Text("Pover supply V", style: headerStyle),
            Text(": ${state?.powerSupplyVoltage} ", style: bodyStyle)
          ],
        ),
        rowSpacer,
        TableRow(
          children: [
            Text("Alarm", style: headerStyle),
            Wrap(
              children: state?.alarm
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Chip(
                            label: Text(
                              e.name.split('_').join(' ').toLowerCase(),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12),
                            ),
                            visualDensity: VisualDensity.compact,
                            clipBehavior: Clip.antiAlias,
                          ),
                        ),
                      )
                      .toList() ??
                  [],
            )
          ],
        ),
      ],
    );
  }
}
