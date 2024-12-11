import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

void main() async {
  // Create a picture using CustomPaint
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  final size = const Size(1024, 1024);
  final paint = Paint()
    ..color = const Color(0xFF6C63FF)
    ..style = PaintingStyle.fill;
  
  // Draw background
  canvas.drawRect(Offset.zero & size, paint);
  
  // Draw genie lamp
  final lampPath = Path()
    ..moveTo(size.width * 0.3, size.height * 0.6)
    ..quadraticBezierTo(
      size.width * 0.4, size.height * 0.7,
      size.width * 0.5, size.height * 0.6,
    )
    ..lineTo(size.width * 0.7, size.height * 0.6)
    ..quadraticBezierTo(
      size.width * 0.8, size.height * 0.6,
      size.width * 0.8, size.height * 0.7,
    )
    ..lineTo(size.width * 0.2, size.height * 0.7)
    ..close();
  
  canvas.drawPath(
    lampPath,
    Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill,
  );
  
  // Draw smoke/magic effect
  final smokePath = Path()
    ..moveTo(size.width * 0.5, size.height * 0.3)
    ..quadraticBezierTo(
      size.width * 0.6, size.height * 0.2,
      size.width * 0.5, size.height * 0.1,
    )
    ..quadraticBezierTo(
      size.width * 0.4, size.height * 0.2,
      size.width * 0.5, size.height * 0.3,
    );
  
  canvas.drawPath(
    smokePath,
    Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill,
  );
  
  final picture = recorder.endRecording();
  final img = await picture.toImage(1024, 1024);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();
  
  // Save the image
  final file = File(path.join('assets', 'icon', 'icon.png'));
  await file.parent.create(recursive: true);
  await file.writeAsBytes(buffer);
  
  // ignore: avoid_print
  print('Icon generated successfully at ${file.path}');
  exit(0);
} 