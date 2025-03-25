import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FavoriteNotification extends StatefulWidget {
  final String message;
  final VoidCallback? onDismissed;

  const FavoriteNotification({
    super.key,
    required this.message,
    this.onDismissed,
  });

  @override
  State<FavoriteNotification> createState() => _FavoriteNotificationState();
}

class _FavoriteNotificationState extends State<FavoriteNotification> {
  @override
  void initState() {
    super.initState();
    _startDismissTimer();
  }

  void _startDismissTimer() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        widget.onDismissed?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 32),
      decoration: BoxDecoration(
        color: Color(0x252525).withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Color(0xFF7C7C7C).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(widget.message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              )),
    );
  }
}
