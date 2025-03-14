import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../../core/device/device_interface.dart';
import '../../../../core/theme/app_colors.dart';

class DeviceList extends StatelessWidget {
  final List<Device> devices;
  final Function(Device) onDeviceSelected;
  final Device? connectedDevice;
  final bool isConnecting;

  const DeviceList({
    super.key,
    required this.devices,
    required this.onDeviceSelected,
    this.connectedDevice,
    this.isConnecting = false,
  });

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return const Center(
        child: Text(
          'No devices found',
          style: TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: devices.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final device = devices[index];
        final isConnected = connectedDevice?.id == device.id;
        
        return DeviceListItem(
          device: device,
          isConnected: isConnected,
          isConnecting: isConnecting && connectedDevice?.id == device.id,
          onTap: () {
            HapticFeedback.selectionClick();
            onDeviceSelected(device);
          },
        );
      },
    );
  }
}

class DeviceListItem extends StatelessWidget {
  final Device device;
  final bool isConnected;
  final bool isConnecting;
  final VoidCallback onTap;

  const DeviceListItem({
    super.key,
    required this.device,
    required this.isConnected,
    required this.isConnecting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isConnected ? AppColors.primary.withOpacity(0.1) : null,
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.separator,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            _buildDeviceIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDeviceStatusText(),
                    style: TextStyle(
                      fontSize: 14,
                      color: isConnected ? AppColors.primary : CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (device.distance != null)
              Text(
                '${device.distance!.toStringAsFixed(1)} m',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            const SizedBox(width: 8),
            if (isConnecting)
              const CupertinoActivityIndicator()
            else
              Icon(
                isConnected ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.chevron_right,
                color: isConnected ? AppColors.primary : CupertinoColors.systemGrey,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceIcon() {
    IconData iconData;
    
    switch (device.type) {
      case DeviceType.smartphone:
        iconData = CupertinoIcons.device_phone_portrait;
        break;
      case DeviceType.watch:
        iconData = CupertinoIcons.app_fill;
        break;
      case DeviceType.tablet:
        iconData = CupertinoIcons.device_phone_landscape;
        break;
      case DeviceType.headphones:
        iconData = CupertinoIcons.headphones;
        break;
      case DeviceType.other:
      default:
        iconData = CupertinoIcons.nosign;
        break;
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.featuresBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        iconData,
        color: isConnected ? AppColors.primary : CupertinoColors.systemGrey,
        size: 20,
      ),
    );
  }

  String _getDeviceStatusText() {
    switch (device.status) {
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.connecting:
        return 'Connecting...';
      case ConnectionStatus.ranging:
        return 'Ranging';
      case ConnectionStatus.disconnected:
      default:
        return 'Tap to connect';
    }
  }
} 