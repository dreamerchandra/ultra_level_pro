import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_non_linear_state.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_state.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/tank_type.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/non_linear_ble_writer.dart';
import 'package:ultra_level_pro/components/widgets/common/common.dart';
import 'package:ultra_level_pro/components/widgets/common/input.dart';
import 'package:ultra_level_pro/components/widgets/device_detail/non_linear/non_linear_create_widget.dart';
import 'package:ultra_level_pro/components/widgets/device_detail/non_linear/non_linear_details_widget.dart';
import 'package:ultra_level_pro/components/widgets/device_detail/shapes_widget.dart';
import 'package:ultra_level_pro/main.dart';

const headerStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w900,
);

const bodyStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w900,
);

Widget headerText(String text) {
  return Text(
    text,
    style: headerStyle,
  );
}

Widget bodyText(String text) {
  return Text(
    text,
    style: bodyStyle,
  );
}

class TankDetailsWidget extends StatefulWidget {
  const TankDetailsWidget({
    super.key,
    required this.state,
    required this.onDone,
    required this.ble,
    required this.onTankTypeChange,
    required this.nonLinearState,
  });

  final Future<bool> Function(WriteParameter parameter, String value) onDone;
  final Future<bool> Function(NonLinearBleWriter changer) onTankTypeChange;

  final BleState? state;
  final BleNonLinearState? nonLinearState;
  final FlutterReactiveBle ble;

  @override
  State<TankDetailsWidget> createState() => _TankDetailsWidgetState();
}

class _TankDetailsWidgetState extends State<TankDetailsWidget> {
  final List<String> tankTypes = TankType.values.map((e) => e.name).toList();
  late NonLinearBleWriter changer = NonLinearBleWriter(ble: widget.ble);

  String getValidationText(String? text) {
    if (text == null || text.isEmpty) {
      return "Value can't be empty";
    }
    return "";
  }

  // ignore: non_constant_identifier_names
  Widget FormInput({
    required String hintText,
    required String labelText,
    required WriteParameter parameter,
    required void Function(WriteParameter parameter, String value) onDone,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(labelText),
          const SizedBox(width: 20),
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: hintText,
              ),
              validator: getValidationText,
              onChanged: (value) {
                onDone(parameter, value);
              },
              textInputAction: TextInputAction.next,
            ),
          ),
        ],
      ),
    );
  }

  bool isError = false;

  void bottomSheetBuilder(BuildContext context, TankType tankType) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return NonLinearBottomSheet(
          isError: isError,
          ble: widget.ble,
          changer: changer,
          onTankTypeChange: widget.onTankTypeChange,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          // Set a minimum height equal to the screen height
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            shape(widget.state?.tankType),
            Table(
              defaultColumnWidth: const FlexColumnWidth(2),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    headerText("Tank type"),
                    bodyText(': ${widget.state?.tankType.name}'),
                    formItem(
                      DropdownButton<String>(
                        isExpanded: true,
                        focusColor: Colors.green,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        underline: Container(),
                        value: widget.state?.tankType.name ?? tankTypes[0],
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: tankTypes.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(
                              items
                                  .split(RegExp(r"(?=[A-Z])"))
                                  .join(' ')
                                  .capitalize(),
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            final tankType = TankType.values.firstWhere(
                                (element) => element.name == newValue);
                            widget.onDone(WriteParameter.TankType,
                                getTankTypeInHex(tankType));
                          }
                        },
                      ),
                    )
                  ],
                ),
                tableGap(),
                if (widget.state?.tankType != TankType.nonLinear) ...[
                  TableRow(
                    children: [
                      headerText("Tank offset mm"),
                      bodyText(': ${widget.state?.tankOffset}'),
                      formItem(
                        Input(
                          hintText: "Tank offset",
                          onDone: widget.onDone,
                          parameter: WriteParameter.TankOffset,
                        ),
                      )
                    ],
                  ),
                  tableGap(),
                  TableRow(
                    children: [
                      headerText("Tank height mm"),
                      bodyText(': ${widget.state?.tankHeight}'),
                      formItem(
                        Input(
                          hintText: "Tank height",
                          onDone: widget.onDone,
                          parameter: WriteParameter.TankHeight,
                        ),
                      )
                    ],
                  ),
                  tableGap(),
                  TableRow(
                    children: [
                      headerText("Tank Length mm"),
                      bodyText(': ${widget.state?.tankLength}'),
                      formItem(
                        Input(
                          hintText: "Tank Length",
                          onDone: widget.onDone,
                          parameter: WriteParameter.TankLength,
                        ),
                      )
                    ],
                  ),
                  tableGap(),
                  TableRow(
                    children: [
                      headerText("Median Filter"),
                      bodyText(': ${widget.state?.damping}'),
                      formItem(
                        Input(
                          hintText: "5",
                          onDone: (parameter, value) {
                            return widget.onDone(
                              parameter,
                              value,
                            );
                          },
                          parameter: WriteParameter.Damping,
                        ),
                      )
                    ],
                  ),
                  tableGap(),
                  TableRow(
                    children: [
                      headerText("Moving Average"),
                      bodyText(': ${widget.state?.temperature1}'),
                      formItem(
                        Input(
                          hintText: "5",
                          onDone: (parameter, value) {
                            return widget.onDone(
                              parameter,
                              value,
                            );
                          },
                          parameter: WriteParameter.Temperature1,
                        ),
                      )
                    ],
                  ),
                  tableGap(),
                  TableRow(
                    children: [
                      headerText("Tank Profile"),
                      bodyText(': ${widget.state?.temperature2}'),
                      formItem(
                        Input(
                          hintText: "5",
                          onDone: (parameter, value) {
                            return widget.onDone(
                              parameter,
                              value,
                            );
                          },
                          parameter: WriteParameter.Temperature2,
                        ),
                      )
                    ],
                  ),
                  if (widget.state?.tankType == TankType.rectangle ||
                      widget.state?.tankType == TankType.elliptical) ...[
                    tableGap(),
                    TableRow(
                      children: [
                        headerText("Tank Width mm"),
                        bodyText(': ${widget.state?.tankWidth}'),
                        formItem(
                          Input(
                            hintText: "Tank Length",
                            onDone: widget.onDone,
                            parameter: WriteParameter.TankWidth,
                          ),
                        )
                      ],
                    ),
                  ] else ...[
                    tableGap(),
                    TableRow(
                      children: [
                        headerText("Tank Diameter mm"),
                        bodyText(': ${widget.state?.tankDiameter}'),
                        formItem(
                          Input(
                            hintText: "Tank Diameter",
                            onDone: widget.onDone,
                            parameter: WriteParameter.TankLength,
                          ),
                        )
                      ],
                    ),
                  ],
                  tableGap(),
                  TableRow(
                    children: [
                      headerText("Low level Relay mm"),
                      bodyText(": ${widget.state?.lowLevelRelayInMm} "),
                      formItem(
                        Input(
                          hintText: "Low level relay",
                          onDone: widget.onDone,
                          parameter: WriteParameter.LowLevelRelayInMm,
                        ),
                      )
                    ],
                  ),
                  tableGap(),
                  TableRow(
                    children: [
                      headerText("High level Relay mm"),
                      bodyText(": ${widget.state?.highLevelRelayInPercent}"),
                      formItem(
                        Input(
                          hintText: "High level relay",
                          onDone: widget.onDone,
                          parameter: WriteParameter.HighLevelRelayInPercent,
                        ),
                      )
                    ],
                  ),
                  tableGap(),
                  TableRow(
                    children: [
                      headerText("LPH"),
                      bodyText(": ${widget.state?.lph}"),
                      formItem(
                        Input(
                          hintText: "Liters per hour",
                          onDone: widget.onDone,
                          parameter: WriteParameter.Lph,
                        ),
                      )
                    ],
                  ),
                ],
              ],
            ),
            if (widget.state?.tankType == TankType.nonLinear) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      bottomSheetBuilder(context, TankType.nonLinear);
                    },
                    child: const Text("Edit Non Linear"),
                  ),
                ],
              ),
              NonLinearTankDetailsWidget(
                state: widget.nonLinearState,
                onChange: (val) async {
                  NonLinearBleWriter changer =
                      NonLinearBleWriter(ble: widget.ble);
                  changer.update(val);
                  return widget.onTankTypeChange(changer);
                },
              )
            ]
          ],
        ),
      ),
    );
  }
}

class NonLinearBottomSheet extends StatefulWidget {
  const NonLinearBottomSheet({
    super.key,
    required this.isError,
    required this.ble,
    required this.changer,
    required this.onTankTypeChange,
  });

  final Future<bool> Function(NonLinearBleWriter changer) onTankTypeChange;
  final bool isError;
  final FlutterReactiveBle ble;
  final NonLinearBleWriter changer;

  @override
  State<NonLinearBottomSheet> createState() => _NonLinearBottomSheetState();
}

class _NonLinearBottomSheetState extends State<NonLinearBottomSheet> {
  bool isError = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      padding: const EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height * 0.65,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 16,
              ),
              Text(
                "Values for Non Linear ${widget.isError ? '(write failed)' : ''}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              NonLinearTankTypeChangerWidget(
                ble: widget.ble,
                onChange: (val) {
                  widget.changer.update(val);
                },
                isError: widget.isError,
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Cancel"),
                ),
                const SizedBox(
                  width: 8,
                ),
                MaterialButton(
                  color: Colors.purple[600],
                  textTheme: ButtonTextTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onPressed: () async {
                    try {
                      await widget.onTankTypeChange(widget.changer);
                      if (context.mounted && Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (!context.mounted) {
                        return;
                      }
                      setState(() {
                        isError = true;
                      });
                    }
                  },
                  child: Text(widget.isError ? 'Write Failed' : "Save"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
