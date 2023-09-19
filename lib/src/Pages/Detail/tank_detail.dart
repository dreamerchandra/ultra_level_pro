import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TankDetails extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Color(0xFF05004E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10 * 0.01),
          bottomLeft: Radius.circular(10 * 0.01),
        ),
      ),
    );
  }
}
