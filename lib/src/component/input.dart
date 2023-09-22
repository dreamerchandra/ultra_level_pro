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
  bool isError = false;
  String value = '';
  @override
  void initState() {
    textController.addListener(() {
      setState(() {
        value = textController.value.text;
      });
    });
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
            style: TextStyle(
              fontSize: 12,
              color: isError ? Colors.red : Colors.black,
            ),
            controller: textController,
          ),
        ),
        value.isNotEmpty
            ? IconButton(
                onPressed: () async {
                  try {
                    setState(() {
                      loading = true;
                      isError = false;
                    });
                    await widget.onDone(
                      widget.parameter,
                      textController.text,
                    );
                    setState(() {
                      loading = false;
                      isError = false;
                    });
                    textController.clear();
                  } catch (e) {
                    debugPrint("error: $e");
                    setState(() {
                      loading = false;
                      isError = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Failed to sent message"),
                    ));
                  }
                },
                icon: loading
                    ? const Icon(Icons.circle_outlined)
                    : const Icon(Icons.check),
                color: isError ? Colors.red : Colors.black,
                iconSize: 15,
              )
            : SizedBox()
      ],
    );
  }
}
