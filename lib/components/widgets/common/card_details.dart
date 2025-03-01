import 'package:flutter/material.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_state.dart';
import 'package:ultra_level_pro/components/widgets/common/expansion_tile_widget.dart';

class CardDetails extends StatefulWidget {
  final BleState? state;
  final Widget header;
  final Widget body;
  final bool initialExpanded;
  final MyExpansionTileController? controller;
  final double width;

  const CardDetails({
    Key? key,
    required this.state,
    required this.header,
    required this.body,
    required this.initialExpanded,
    this.controller,
    required this.width,
  }) : super(key: key);

  @override
  State<CardDetails> createState() => _CardDetailsState();
}

class _CardDetailsState extends State<CardDetails> {
  late bool isExpanded;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.initialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MyExpansionTile(
          initiallyExpanded: widget.initialExpanded,
          controller: widget.controller,
          title: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(child: widget.header),
                isExpanded
                    ? const Icon(
                        Icons.expand_less,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.expand_more,
                        color: Colors.white,
                      ),
              ],
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          leading: const SizedBox(),
          onExpansionChanged: (value) => {
            setState(() {
              isExpanded = value;
            })
          },
          children: [
            Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ), //BorderRadius.all
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 36.0,
                      horizontal: 12.0,
                    ),
                    child: widget.body,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
