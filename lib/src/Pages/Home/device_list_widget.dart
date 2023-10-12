import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class DeviceListWidget extends StatelessWidget {
  const DeviceListWidget(
      {super.key, required this.devices, required this.onTap});
  final List<DiscoveredDevice> devices;
  final Function(DiscoveredDevice) onTap;

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) return const Center(child: Text("No device found"));
    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return ListTile(
          title: Text(device.name),
          subtitle: Text(device.id),
          trailing: Text(device.rssi.toString()),
          onTap: () {
            onTap(device);
          },
        );
      },
    );
  }
}
