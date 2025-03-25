import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:screenshot/screenshot.dart';

class WidgetCapture {
  static final WidgetCapture _instance = WidgetCapture._internal();

  static WidgetCapture get instance => _instance;

  final ScreenshotController _controller = ScreenshotController();

  WidgetCapture._internal();

  Future<BitmapDescriptor> widgetToAppleMarker({
    required Widget widget,
    required double width,
    required double height,
    double pixelRatio = 2.0,
  }) async {
    try {
      // Создаем контейнер с нашим виджетом
      final Widget container = Material(
        color: Colors.transparent,
        child: SizedBox(
          width: width,
          height: height,
          child: widget,
        ),
      );

      final Uint8List capturedImage = await _controller.captureFromWidget(
        container,
        pixelRatio: pixelRatio,
        delay: const Duration(milliseconds: 10),
      );

      return BitmapDescriptor.fromBytes(capturedImage);
    } catch (e) {
      print('Error creating bitmap descriptor: $e');
      return BitmapDescriptor.defaultAnnotation;
    }
  }
}

Future<BitmapDescriptor> widgetToAppleMarker(
  Widget widget, {
  required double width,
  required double height,
}) {
  return WidgetCapture.instance.widgetToAppleMarker(
    widget: widget,
    width: width,
    height: height,
  );
}
