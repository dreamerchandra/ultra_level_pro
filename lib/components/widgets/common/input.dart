import 'package:flutter/material.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/constant.dart';

class Input extends StatefulWidget {
  const Input({
    super.key,
    required this.hintText,
    required this.onDone,
    required this.parameter,
    this.textInputAction,
  });
  final String hintText;
  final Future<void> Function(WriteParameter, String) onDone;
  final WriteParameter parameter;
  final TextInputAction? textInputAction;

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
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            autocorrect: false,
            keyboardType: TextInputType.number,
            textInputAction: widget.textInputAction,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: MaterialStateTextStyle.resolveWith(
                (states) => TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isError ? Colors.red : Colors.black,
            ),
            controller: textController,
          ),
        ),
        value.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: IconButton(
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
                      if (context.mounted) {
                        setState(() {
                          loading = false;
                          isError = true;
                        });
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Failed to sent message"),
                        ));
                      }
                    }
                  },
                  icon: loading
                      ? const Icon(Icons.circle_outlined)
                      : const Icon(Icons.check),
                  color: isError ? Colors.red : Colors.black,
                  iconSize: 15,
                ),
              )
            : SizedBox()
      ],
    );
  }
}
