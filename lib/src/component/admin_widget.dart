import 'package:flutter/material.dart';
import 'package:otp/otp.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/constant.dart';

class AdminWidget extends StatefulWidget {
  const AdminWidget({Key? key, required this.isAdmin, required this.setIsAdmin})
      : super(key: key);
  final bool isAdmin;
  final void Function(bool isAdmin) setIsAdmin;

  @override
  State<AdminWidget> createState() => _AdminWidgetState();
}

class _AdminWidgetState extends State<AdminWidget> {
  late TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AdminWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: widget.isAdmin ? Colors.greenAccent[400] : null,
      foregroundColor:
          widget.isAdmin ? Colors.green[900] : Colors.blueGrey[900],
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Make me Admin"),
            content: TextField(
              autocorrect: false,
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "OTP",
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("No")),
              TextButton(
                  onPressed: () {
                    String code = OTP.generateTOTPCodeString(
                      TOTP_SECRET,
                      DateTime.utc(DateTime.now().year).millisecondsSinceEpoch,
                      algorithm: Algorithm.SHA512,
                      interval: 60 * 10,
                      length: 6,
                    );
                    if (SUPER_ADMIN_CODE == _controller.text) {
                      _controller.value = TextEditingValue(
                        text: code,
                      );
                      return;
                    }
                    if (code != _controller.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Wrong OTP"),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("You are now Admin"),
                        ),
                      );
                    }
                    widget.setIsAdmin(code == _controller.text);
                    _controller.clear();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Yes",
                  )),
            ],
          ),
        );
      },
      child: widget.isAdmin
          ? const Icon(Icons.key_rounded)
          : const Icon(Icons.admin_panel_settings_outlined),
    );
  }
}
