import 'package:flutter/material.dart';

class Rssid extends StatelessWidget {
  const Rssid({super.key, required this.rssid});
  final int rssid;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "${rssid}dBm",
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                  shape: BoxShape.rectangle,
                  color: rssid < -100 ? Colors.white : Colors.amber,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                  shape: BoxShape.rectangle,
                  color:
                      rssid < -86 && rssid < -100 ? Colors.white : Colors.amber,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                  shape: BoxShape.rectangle,
                  color: rssid < -85 ? Colors.white : Colors.amber,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              ),
            ],
          ),
        )
      ],
    );
  }
}
