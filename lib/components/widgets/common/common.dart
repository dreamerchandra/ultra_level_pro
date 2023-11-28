import 'package:flutter/material.dart';

Widget formItem(Widget child) {
  return SizedBox(
    height: 22,
    child: child,
  );
}

TableRow tableGap() {
  return const TableRow(
    children: [
      SizedBox(
        height: 36,
      ),
      SizedBox(
        height: 36,
      ),
      SizedBox(
        height: 36,
      ),
    ],
  );
}

const rowSpacer = TableRow(children: [
  SizedBox(
    height: 12,
  ),
  SizedBox(
    height: 12,
  )
]);
