import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_non_linear_state.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/components/widgets/common/input.dart';

const headerStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w900,
);

const bodyStyle = TextStyle(
  fontSize: 14,
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

class NonLinearCreateWidget extends StatefulWidget {
  const NonLinearCreateWidget({
    super.key,
    required this.initialState,
    required this.onChange,
    required this.onReset,
  });
  final List<NonLinearParameter> initialState;
  final void Function() onReset;
  final Future<bool> Function(List<NonLinearParameter> val) onChange;

  @override
  State<NonLinearCreateWidget> createState() => _NonLinearCreateWidget();
}

class _NonLinearCreateWidget extends State<NonLinearCreateWidget> {
  List<NonLinearParameter> state = [];
  @override
  void initState() {
    state = widget.initialState;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...widget.initialState.mapIndexed((idx, e) {
            return SingleNonLinearTankDetailsWidget(
              index: idx,
              height: e.height,
              filled: e.filled,
              onRemove: (index) async {
                List<NonLinearParameter> newState = List.from(state)
                  ..removeAt(index);
                setState(() {
                  state = newState;
                });
                return Future.value(true);
              },
              onHeightChange: (index, height) async {
                final res = state.mapIndexed((idx, element) {
                  if (idx == index) {
                    return NonLinearParameter(
                        height: int.parse(height), filled: element.filled);
                  }
                  return element;
                }).toList();
                setState(() {
                  state = res;
                });
                return Future.value(true);
              },
              onFilledChange: (index, filled) async {
                final res = state.mapIndexed((idx, element) {
                  if (idx == index) {
                    return NonLinearParameter(
                        height: element.height, filled: int.parse(filled));
                  }
                  return element;
                }).toList();
                setState(() {
                  state = res;
                });
                return Future.value(true);
              },
            );
          }).toList(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(30, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () {
                  widget.onReset();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.green, fontSize: 10),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              FilledButton(
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () async {
                  widget.onChange(state);
                },
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.green, fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SingleNonLinearTankDetailsWidget extends StatelessWidget {
  const SingleNonLinearTankDetailsWidget({
    super.key,
    required this.index,
    required this.height,
    required this.filled,
    required this.onRemove,
    required this.onHeightChange,
    required this.onFilledChange,
  });
  final int index;
  final int height;
  final int filled;
  final Future<bool> Function(int index) onRemove;
  final Future<bool> Function(int index, String height) onHeightChange;
  final Future<bool> Function(int index, String filled) onFilledChange;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrain) {
      return SizedBox(
        width: constrain.maxWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '# ${index + 1}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(30, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () {
                        onRemove(index);
                      },
                      child: const Text(
                        'Remove',
                        style: TextStyle(color: Colors.red, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Height:',
                          style: bodyStyle,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          height.toString(),
                          style: bodyStyle,
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: Input(
                            hintText: "Tank Height",
                            onDone: (_, val) {
                              return onHeightChange(index, val);
                            },
                            parameter: WriteParameter.TankHeight,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Filled:',
                          style: bodyStyle,
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Text(
                          filled.toString(),
                          style: bodyStyle,
                        ),
                        const SizedBox(
                          width: 24,
                        ),
                        Expanded(
                          child: Input(
                            hintText: "Tank Filled",
                            onDone: (_, val) {
                              return onFilledChange(index, val);
                            },
                            parameter: WriteParameter.TankHeight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
