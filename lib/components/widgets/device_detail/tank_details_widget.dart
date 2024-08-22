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

bool shouldApply(WriteParameter parameter, TankType? tankType) {
  if (tankType == null) {
    return false;
  }
  if (parameter == WriteParameter.TankHeight) {
    return true;
  }
  const diameter = [
    TankType.horizontalCylinder,
    TankType.verticalCylinder,
    TankType.horizontalCapsule,
    TankType.verticalCapsule
  ];
  const length = [
    TankType.horizontalCylinder,
    TankType.rectangle,
    TankType.horizontalOval,
    TankType.verticalOval,
    TankType.horizontalCapsule,
    TankType.verticalCapsule,
  ];
  const width = [
    TankType.rectangle,
    TankType.horizontalOval,
    TankType.verticalOval,
  ];
  const height = [
    TankType.verticalCylinder,
    TankType.rectangle,
    TankType.horizontalOval,
    TankType.verticalOval,
  ];
  if (diameter.contains(tankType) && parameter == WriteParameter.TankDiameter) {
    return true;
  }
  if (length.contains(tankType) && parameter == WriteParameter.TankLength) {
    return true;
  }
  if (width.contains(tankType) && parameter == WriteParameter.TankWidth) {
    return true;
  }
  if (height.contains(tankType) && parameter == WriteParameter.TankHeight) {
    return true;
  }
  return false;
}

class TankDetailsWidget extends StatefulWidget {
  const TankDetailsWidget({
    super.key,
    required this.state,
    required this.onDone,
    required this.ble,
    required this.onTankTypeChange,
    required this.nonLinearState,
    required this.pauseTimer,
    required this.resumeTimer,
  });

  final Future<bool> Function(WriteParameter parameter, String value) onDone;
  final Future<bool> Function(NonLinearBleWriter changer) onTankTypeChange;
  final void Function() pauseTimer;
  final void Function() resumeTimer;

  final BleState? state;
  final BleNonLinearState? nonLinearState;
  final FlutterReactiveBle ble;

  @override
  State<TankDetailsWidget> createState() => _TankDetailsWidgetState();
}

class _TankDetailsWidgetState extends State<TankDetailsWidget> {
  final List<String> tankTypes = TankType.values.map((e) => e.name).toList();
  late NonLinearBleWriter changer = NonLinearBleWriter(ble: widget.ble);
  bool nonLinearEdit = false;
  List<NonLinearParameter> nonLinearInitialValues = [];

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
              defaultColumnWidth: const FlexColumnWidth(1),
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
                          hintText: "0-3",
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
                  if (shouldApply(
                      WriteParameter.TankHeight, widget.state?.tankType)) ...[
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
                  ],
                  if (shouldApply(
                      WriteParameter.TankLength, widget.state?.tankType)) ...[
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
                  ],
                  if (shouldApply(
                      WriteParameter.TankWidth, widget.state?.tankType)) ...[
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
                  ],
                  if (shouldApply(
                      WriteParameter.TankDiameter, widget.state?.tankType)) ...[
                    tableGap(),
                    TableRow(
                      children: [
                        headerText("Tank Diameter mm"),
                        bodyText(': ${widget.state?.tankDiameter}'),
                        formItem(
                          Input(
                            hintText: "Tank Diameter",
                            onDone: widget.onDone,
                            parameter: WriteParameter.TankDiameter,
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
                      headerText("High level Relay %"),
                      bodyText(
                          ": ${(widget.state?.highLevelRelayInPercent ?? 0) * 100}%"),
                      formItem(
                        Input(
                          hintText: "High level relay %",
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
                  headerText("Tank Length"),
                  bodyText(
                    ": ${widget.nonLinearState?.nonLinearParameters.length ?? 0}",
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Input(
                      hintText: "Non linear tanks lengths",
                      onDone: (value, val) {
                        int size = int.parse(val);
                        widget.pauseTimer();
                        List<NonLinearParameter> initialValues = [];
                        for (int i = 0; i < size; i++) {
                          if (widget
                                  .nonLinearState!.nonLinearParameters.length >
                              i) {
                            initialValues.add(
                                widget.nonLinearState!.nonLinearParameters[i]);
                          } else {
                            initialValues
                                .add(NonLinearParameter(height: 0, filled: 0));
                          }
                        }
                        setState(() {
                          nonLinearEdit = true;
                          nonLinearInitialValues = initialValues;
                        });
                        return Future.value();
                      },
                      parameter: WriteParameter.TankLength,
                    ),
                  ),
                ],
              ),
              if (nonLinearEdit) ...[
                NonLinearCreateWidget(
                  initialState: nonLinearInitialValues,
                  onReset: () {
                    setState(() {
                      nonLinearEdit = false;
                      nonLinearInitialValues = [];
                    });
                    widget.resumeTimer();
                  },
                  onChange: (val) async {
                    changer.update(val);
                    return widget.onTankTypeChange(changer);
                  },
                )
              ] else ...[
                NonLinearTankDetailsWidget(
                  state: widget.nonLinearState,
                  onChange: (val) async {
                    NonLinearBleWriter changer =
                        NonLinearBleWriter(ble: widget.ble);
                    changer.update(val);
                    final res = await widget.onTankTypeChange(changer);
                    if (res) {
                      setState(() {
                        nonLinearEdit = false;
                        nonLinearInitialValues = [];
                      });
                    }
                    return res;
                  },
                )
              ]
            ]
          ],
        ),
      ),
    );
  }
}
