import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ultra_level_pro/src/Pages/Detail/Cards/common.dart';
import 'package:ultra_level_pro/src/Pages/Detail/shapes_widget.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/ble_reader.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/tank_type.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/tank_type_changer.dart';
import 'package:ultra_level_pro/src/component/input.dart';

class TankDetailsWidget extends StatefulWidget {
  TankDetailsWidget({
    super.key,
    required this.state,
    required this.onDone,
    required this.ble,
    required this.onTankTypeChange,
  });

  final Future<bool> Function(WriteParameter parameter, String value) onDone;
  final Future<bool> Function(TankTypeChanger changer) onTankTypeChange;

  final BleState? state;
  final FlutterReactiveBle ble;

  @override
  State<TankDetailsWidget> createState() => _TankDetailsWidgetState();
}

class _TankDetailsWidgetState extends State<TankDetailsWidget> {
  final List<String> tankTypes = TankType.values.map((e) => e.name).toList();
  late TankTypeChanger changer = TankTypeChanger(ble: widget.ble);
  final _form = GlobalKey<FormState>();

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

  void bottomSheetBuilder(BuildContext context, TankType tankType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Values for ${getTankLabel(tankType)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _form,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            {
                              "labelText": "Tank height",
                              "hintText": "mm",
                              "parameter": WriteParameter.TankHeight
                            },
                            {
                              "labelText": "Tank Length",
                              "hintText": "mm",
                              "parameter": WriteParameter.TankLength
                            },
                            {
                              "labelText": "Tank Width",
                              "hintText": "mm",
                              "parameter": WriteParameter.TankWidth
                            },
                          ]
                              .map((e) => FormInput(
                                    hintText: e["hintText"] as String,
                                    labelText: e["labelText"] as String,
                                    parameter: e["parameter"] as WriteParameter,
                                    onDone: (WriteParameter parameter,
                                        String value) {
                                      changer.set(
                                          parameter: parameter, value: value);
                                    },
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => {
                          Navigator.pop(context),
                        },
                        child: Text("Cancel"),
                      ),
                      MaterialButton(
                        color: Colors.purple[600],
                        textTheme: ButtonTextTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onPressed: () async {
                          if (_form.currentState == null) {
                            return;
                          }
                          final isValid = _form.currentState?.validate();
                          if (isValid == null || !isValid) {
                            return;
                          }
                          // try {
                          //   await widget.onTankTypeChange(changer);
                          //   if (context.mounted) {
                          //     Navigator.pop(context);
                          //   }
                          // } catch (e) {
                          //   if (!context.mounted) {
                          //     return;
                          //   }
                          //   ScaffoldMessenger.of(context).showMaterialBanner(
                          //     const MaterialBanner(
                          //       content: Text(
                          //           "Changing failed try again after some time"),
                          //       actions: [],
                          //     ),
                          //   );
                          // }
                        },
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        shape(widget.state?.tankType),
        Table(
          defaultColumnWidth: FlexColumnWidth(2),
          children: [
            TableRow(
              children: [
                Text("Tank type"),
                Text(': ${widget.state?.tankType.name}'),
                formItem(
                  DropdownButton<String>(
                    isExpanded: true,
                    focusColor: Colors.green,
                    style: TextStyle(color: Colors.black87),
                    underline: Container(),
                    value: widget.state?.tankType.name ?? tankTypes[0],
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: tankTypes.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        final tankType = TankType.values
                            .firstWhere((element) => element.name == newValue);
                        bottomSheetBuilder(context, tankType);
                      }
                    },
                  ),
                )
              ],
            ),
            tableGap(),
            TableRow(
              children: [
                Text("Tank height"),
                Text(': ${widget.state?.tankHeight} mm'),
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
                Text("Tank Lenght"),
                Text(': ${widget.state?.tankLength} mm'),
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
                Text("Tank Diameter"),
                Text(": ${widget.state?.tankWidth} mm"),
                formItem(
                  Input(
                    hintText: "Tank diameter",
                    onDone: widget.onDone,
                    parameter: WriteParameter.TankWidth,
                  ),
                )
              ],
            ),
            tableGap(),
            TableRow(
              children: [
                Text("Low level Relay"),
                Text(": ${widget.state?.lowLevelRelayInMm} mm"),
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
                Text("High level Relay"),
                Text(": ${widget.state?.highLevelRelayInPercent} %"),
                formItem(
                  Input(
                    hintText: "High level relay",
                    onDone: widget.onDone,
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
