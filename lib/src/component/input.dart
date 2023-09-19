import 'package:flutter/material.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/constant.dart';

class Input extends StatefulWidget {
  const Input({
    super.key,
    required this.hintText,
    required this.onDone,
    required this.parameter,
  });
  final String hintText;
  final Future<void> Function(WriteParameter, String) onDone;
  final WriteParameter parameter;

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  final textController = TextEditingController();
  bool loading = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            autocorrect: false,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: widget.hintText,
            ),
            style: const TextStyle(fontSize: 12),
            controller: textController,
          ),
        ),
        IconButton(
          onPressed: () async {
            setState(() {
              loading = true;
            });
            await widget.onDone(
              widget.parameter,
              textController.text,
            );
            setState(() {
              loading = false;
            });
            textController.clear();
          },
          icon: loading
              ? const Icon(Icons.circle_outlined)
              : const Icon(Icons.check),
          iconSize: 15,
        )
      ],
    );
  }
}
