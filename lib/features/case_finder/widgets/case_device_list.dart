import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pod_finder_pro_178/gen/assets.gen.dart';
import '../../../core/models/device.dart';
import '../../../core/theme/app_colors.dart';
import '../presentation/bloc/case_finder_bloc.dart';
import '../../finder/presentation/widgets/help_panel.dart';
import '../../finder/presentation/screens/device_tracking_screen.dart';

class CaseDeviceList extends StatelessWidget {
  final List<Device> devices;

  const CaseDeviceList({
    super.key,
    required this.devices,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2F2F7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 16, left: 16),
            child: Text(
              'AirPods & Cases (${devices.length})',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        children:
                            List.generate(devices.length * 2 - 1, (index) {
                          if (index % 2 == 0) {
                            return CaseDeviceListItem(device: devices[index ~/ 2]);
                          } else {
                            return const Divider(
                              height: 1,
                              indent: 60,
                              endIndent: 0,
                              color: Color(0xFFE0E0E0),
                            );
                          }
                        }),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => HelpPanel.show(context),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Can't find your AirPods?",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 16,
                              width: 18,
                              child: SvgPicture.asset(Assets.vector.info),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CaseDeviceListItem extends StatelessWidget {
  final Device device;

  const CaseDeviceListItem({
    super.key,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    // Get the current CaseFinderBloc instance
    final finderBloc = context.read<CaseFinderBloc>();
    
    return Container(
      color: Colors.white,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          // Use CupertinoPageRoute instead of PageRouteBuilder to avoid framework assertion errors
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => BlocProvider.value(
                value: finderBloc,
                child: DeviceTrackingScreen(device: device),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Center(
                child: _getDeviceIcon(device.name),
              ),
              const SizedBox(width: 12),
              // Device info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name.isEmpty ? "AirPods" : device.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${device.distance != null ? device.distance!.round() : 9} m',
                      style: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Chevron icon
              const Icon(
                CupertinoIcons.chevron_right,
                color: Color(0xFFC7C7CC),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _getDeviceIcon(String deviceName) {
    final name = deviceName.toLowerCase();
    
    if (name.contains('airpods pro') || name.contains('pods pro')) {
      return SvgPicture.asset(
        Assets.vector.airpodsPro,
        width: 42,
        height: 42,
        fit: BoxFit.contain,
        color: AppColors.primary,
      );
    } else if (name.contains('airpods max') || name.contains('max')) {
      return SvgPicture.asset(
        Assets.vector.airpodsMax,
        width: 42,
        height: 42,
        fit: BoxFit.contain,
        color: AppColors.primary,
      );
    } else {
      return SvgPicture.asset(
        Assets.vector.airpods,
        width: 42,
        height: 42,
        fit: BoxFit.contain,
        color: AppColors.primary,
      );
    }
  }
} 