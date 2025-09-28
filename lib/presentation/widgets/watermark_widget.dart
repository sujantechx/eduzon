// lib/presentation/widgets/watermark_widget.dart

import 'package:flutter/material.dart';

// A simple widget that displays a text watermark, typically used over videos.
class WatermarkWidget extends StatelessWidget {
  final String text;
  const WatermarkWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    // IgnorePointer prevents this widget from capturing any user touch events.
    return IgnorePointer(
      child: Center(
        child: Opacity(
          opacity: 0.15, // Low opacity to be unobtrusive
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}