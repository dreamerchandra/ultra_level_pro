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
        return ListTile(
          title: Text(device.name),
          subtitle: Text(device.id),
          trailing: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (connectingDeviceId == device.id) ...[
                const Center(
                  child: CircularProgressIndicator(),
                )
              ],
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Rssid(
                    rssid: device.rssi,
                  ),
                  Text(
                    '${device.rssi} dBM',
                    style: const TextStyle(fontSize: 14),
                  )
                ],
              ),
            ],
          ),
          selectedColor: Colors.grey,
          selected: connectingDeviceId == device.id,
          onTap: () {
            onTap(device);
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    );
  }
}
