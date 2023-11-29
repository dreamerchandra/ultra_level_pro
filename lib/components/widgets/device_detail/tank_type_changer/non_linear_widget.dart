import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/tank_type_changer.dart';

class NonLinearTankTypeChangerWidget extends StatefulWidget {
  const NonLinearTankTypeChangerWidget({
    super.key,
    required this.ble,
    required this.onChange,
  });
  final FlutterReactiveBle ble;
  final void Function(List<List<TankTypeParameter>> val) onChange;

  @override
  State<NonLinearTankTypeChangerWidget> createState() =>
      _NonLinearTankTypeChangerWidgetState();
}

class _NonLinearTankTypeChangerWidgetState
    extends State<NonLinearTankTypeChangerWidget> {
  final _form = GlobalKey<FormState>();
  List<List<TankTypeParameter>> _valuesToCommit = [[]];

  void set(
      {required WriteParameter parameter,
      required String value,
      required int tankIndex}) {
    if (_valuesToCommit.length <= tankIndex) {
      throw ErrorDescription('Something went wrong');
    }
    final index = _valuesToCommit[tankIndex]
        .indexWhere((element) => element.parameter == parameter);
    if (index != -1) {
      _valuesToCommit[tankIndex][index] =
          TankTypeParameter(parameter: parameter, value: value);
    } else {
      _valuesToCommit[tankIndex]
          .add(TankTypeParameter(parameter: parameter, value: value));
    }
    widget.onChange(_valuesToCommit);
    setState(() {
      _valuesToCommit = _valuesToCommit;
    });
  }

  remove(int index) {
    _valuesToCommit.removeAt(index);
    widget.onChange(_valuesToCommit);
    setState(() {
      _valuesToCommit = _valuesToCommit;
    });
  }

  add() {
    _valuesToCommit.add([]);
    widget.onChange(_valuesToCommit);
    setState(() {
      _valuesToCommit = _valuesToCommit;
    });
  }

  String getValidationText(String? text) {
    if (text == null || text.isEmpty) {
      return "Value can't be empty";
    }
    return "";
  }

  Widget FormInput({
    required String hintText,
    required String labelText,
    required WriteParameter parameter,
    required void Function(WriteParameter parameter, String value) onDone,
  }) {
    const textStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            labelText,
            style: textStyle,
          ),
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
              style: textStyle,
              textInputAction: TextInputAction.next,
            ),
          ),
        ],
      ),
    );
  }

  ScrollController itemScroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            const SizedBox(
              height: 8,
            ),
            Form(
              key: _form,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.50,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  controller: itemScroll,
                  itemBuilder: (context, index) => tankInfo(index),
                  itemCount: _valuesToCommit.length,
                ),
              ),
            ),
            const SizedBox(
              height: 48,
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Center(
            child: FilledButton.icon(
              onPressed: () {
                add();
                Future.delayed(const Duration(milliseconds: 500), () {
                  itemScroll.animateTo(
                    itemScroll.position.maxScrollExtent,
                    curve: Curves.bounceIn,
                    duration: const Duration(milliseconds: 500),
                  );
                });
              },
              icon: const Icon(Icons.add),
              label: const Text("Add New"),
            ),
          ),
        )
      ],
    );
  }

  Widget tankInfo(int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueGrey,
          width: 1,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Tank Details #$index"),
                  IconButton.filledTonal(
                    onPressed: () {
                      remove(index);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            ...tankParams(index),
          ],
        ),
      ),
    );
  }

  List<Widget> tankParams(int index) {
    return [
      {
        "labelText": "Tank Offset",
        "hintText": "mm",
        "parameter": WriteParameter.TankOffset
      },
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
              onDone: (WriteParameter parameter, String value) {
                set(parameter: parameter, value: value, tankIndex: index);
              },
            ))
        .toList();
  }
}
