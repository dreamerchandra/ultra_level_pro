import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ultra_level_pro/components/widgets/common/rssid.dart';

class DeviceListWidget extends StatelessWidget {
  const DeviceListWidget({
    super.key,
    required this.devices,
    required this.onTap,
    required this.connectingDeviceId,
  });
  final List<DiscoveredDevice> devices;
  final Function(DiscoveredDevice) onTap;
  final String connectingDeviceId;

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) return const Center(child: Text("No device found"));
    return ListView.separated(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          margin: EdgeInsets.only(top: 10, bottom: 10),
          child: ListTile(
            title: Text(device.name),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              textBaseline: TextBaseline.alphabetic,
              mainAxisSize: MainAxisSize.max,
              children: [
                Rssid(rssid: device.rssi, textColor: Colors.black),
                Text(device.id),
              ],
            ),
            trailing: TextButton(
              onPressed: () {
                onTap(device);
              },
              style: TextButton.styleFrom(
                backgroundColor:
                    connectingDeviceId == device.id
                        ? Colors.grey
                        : const Color.fromARGB(255, 2, 189, 158),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                connectingDeviceId == device.id ? 'Connecting...' : 'Connect',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            selectedColor: Colors.grey,
            selected: connectingDeviceId == device.id,
            onTap: () {
              onTap(device);
            },
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    );
  }
}
