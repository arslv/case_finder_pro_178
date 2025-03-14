import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/models/device.dart';

class DeviceList extends StatelessWidget {
  final List<Device> devices;
  
  const DeviceList({
    Key? key,
    required this.devices,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Found ${devices.length} device${devices.length == 1 ? '' : 's'}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return DeviceListItem(device: device);
            },
          ),
        ),
      ],
    );
  }
}

class DeviceListItem extends StatelessWidget {
  final Device device;
  
  const DeviceListItem({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _buildLeadingIcon(),
        title: Text(
          device.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'ID: ${device.id.substring(0, min(8, device.id.length))}...',
        ),
        trailing: device.distance != null
            ? Text(
                '${device.distance!.toStringAsFixed(1)} m',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildLeadingIcon() {
    IconData iconData;
    Color iconColor;
    
    switch (device.source) {
      case DeviceSource.bluetooth:
        iconData = Icons.bluetooth;
        iconColor = Colors.blue;
        break;
      case DeviceSource.uwb:
        iconData = Icons.wifi_tethering;
        iconColor = Colors.green;
        break;
    }
    
    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(
        iconData,
        color: iconColor,
      ),
    );
  }
}
