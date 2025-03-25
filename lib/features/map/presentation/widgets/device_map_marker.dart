import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pod_finder_pro_178/core/theme/app_colors.dart';
import 'package:pod_finder_pro_178/gen/assets.gen.dart';
import '../../../../core/models/favorite_device.dart';
import '../../../../core/models/device.dart';

class DeviceMapMarker extends StatelessWidget {
  final FavoriteDevice device;

  const DeviceMapMarker({
    super.key,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            _buildDeviceIcon(),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatLastSeen(device.addedAt),
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(fontSize: 11, color: AppColors.secondary),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(Assets.vector.chevronRight),
          ]),
        ),
        // Triangle pointer
        CustomPaint(
          size: const Size(14, 7),
          painter: TrianglePointer(),
        ),
      ],
    );
  }

  /// "Last seen DD MMM, YYYY"
  String _formatLastSeen(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    final DateFormat formatter = DateFormat('d MMM, yyyy');
    
    if (date == today) {
      return 'Last seen today';
    }
    else if (date == today.subtract(const Duration(days: 1))) {
      return 'Last seen yesterday';
    }
    else {
      return 'Last seen ${formatter.format(dateTime)}';
    }
  }

  Widget _buildDeviceIcon() {
    final deviceType = DeviceType.values[device.deviceType];

    switch (deviceType) {
      case DeviceType.smartphone:
        return SvgPicture.asset(
          Assets.vector.blueLogo,
          colorFilter: const ColorFilter.mode(
            CupertinoColors.activeBlue,
            BlendMode.srcIn,
          ),
        );
      case DeviceType.accessory:
        return SvgPicture.asset(
          Assets.vector.airpods,
          colorFilter: const ColorFilter.mode(
            CupertinoColors.activeBlue,
            BlendMode.srcIn,
          ),
        );
      default:
        return SvgPicture.asset(
          Assets.vector.blueLogo,
          width: 32,
          height: 32,
          colorFilter: const ColorFilter.mode(
            CupertinoColors.activeBlue,
            BlendMode.srcIn,
          ),
        );
    }
  }
}

class TrianglePointer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = CupertinoColors.white
      ..style = PaintingStyle.fill;

    final Path path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);

    final Paint shadowPaint = Paint()
      ..color = CupertinoColors.systemGrey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(path, shadowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
