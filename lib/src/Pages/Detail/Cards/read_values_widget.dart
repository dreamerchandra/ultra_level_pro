import 'package:flutter/material.dart';
import 'package:ultra_level_pro/src/Pages/Detail/Cards/common.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/ble_reader.dart';

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
            Text("Level in Liter"),
            Text(': ${state?.levelInLiter} L')
          ],
        ),
        rowSpacer,
        TableRow(
          children: [
            Text("Level in mm"),
            Text(
                ': ${state?.levelInMm} ${state!.settings.isInMM ? 'mm' : 'cm'}')
          ],
        ),
        rowSpacer,
        TableRow(
          children: [
            Text("Level in Perc%"),
            Text(': ${state?.levelInPercent} %')
          ],
        ),
        rowSpacer,
        TableRow(
          children: [
            Text("Alarm"),
            Wrap(
              children: state?.alarm
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Chip(
                            label: Text(
                              e.name.split('_').join(' ').toLowerCase(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
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
        rowSpacer,
        TableRow(
          children: [Text("Version"), Text(": ${state?.version}")],
        ),
        rowSpacer,
        TableRow(
          children: [
            Text("Pover supply V"),
            Text(": ${state?.powerSupplyVoltage} V")
          ],
        ),
        rowSpacer,
      ],
    );
  }
}
