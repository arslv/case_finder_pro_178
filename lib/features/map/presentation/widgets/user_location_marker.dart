import 'package:flutter/cupertino.dart';

class UserLocationMarker extends StatelessWidget {
  final double size;
  
  const UserLocationMarker({
    super.key,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: CupertinoColors.activeBlue,
        shape: BoxShape.circle,
        border: Border.all(
          color: CupertinoColors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.3,
          height: size * 0.3,
          decoration: const BoxDecoration(
            color: CupertinoColors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
} 