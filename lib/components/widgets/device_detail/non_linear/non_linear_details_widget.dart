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
  fontSize: 18,
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

class NonLinearTankDetailsWidget extends StatelessWidget {
  const NonLinearTankDetailsWidget({super.key, required this.state});
  final BleNonLinearState? state;

  @override
  Widget build(BuildContext context) {
    if (state == null) {
      return Container();
    }
    if (state!.nonLinearParameters.isEmpty) {
      return Container();
    }
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: state!.nonLinearParameters.mapIndexed((idx, e) {
        return SingleNonLinearTankDetailsWidget(
          index: idx,
          height: e.height,
          filled: e.filled,
          onRemove: (index) {},
          onHeightChange: (index, height) async {},
          onFilledChange: (index, filled) async {},
        );
      }).toList(),
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
  final void Function(int index) onRemove;
  final Future<void> Function(int index, String height) onHeightChange;
  final Future<void> Function(int index, String filled) onFilledChange;

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
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${index}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      onRemove(index);
                    },
                    child: const Text(
                      'Remove',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 25,
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
                              return onHeightChange(index, val);
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
