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
        height: 24,
      ),
      SizedBox(
        height: 24,
      ),
      SizedBox(
        height: 24,
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
