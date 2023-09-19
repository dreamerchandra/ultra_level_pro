import 'package:flutter/material.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/ble_state.dart';

class CardDetails extends StatelessWidget {
  final BleState? state;
  final Widget header;
  final Widget body;
  const CardDetails(
      {Key? key, required this.state, required this.header, required this.body})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade100, //New
            blurRadius: 15.0,
            offset: Offset(0, -5),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.purple[600],
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                topLeft: Radius.circular(10),
              ), //BorderRadius.all
            ),
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: header,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ), //BorderRadius.all
            ),
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 28.0, 16.0, 16.0),
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}
