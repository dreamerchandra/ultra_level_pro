import 'package:flutter/material.dart';

showAlertDialog({
  required Future<void> Function() onOk,
  VoidCallback? onCancel,
  required BuildContext context,
}) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Exit'),
        content: const Text(
            'Would you like to go back to bluetooth listing screen?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              onCancel?.call();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await onOk();
              Navigator.of(context).pop();
            },
            child: const Text('Go Back'),
          ),
        ],
      );
    },
  );
}
