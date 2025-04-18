// widgets/floating_zoom_buttons.dart
import 'package:flutter/material.dart';

class FloatingZoomButtons extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final double hourHeight;

  const FloatingZoomButtons({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.hourHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'zoomIn',
          mini: true,
          onPressed: onZoomIn,
          child: const Icon(Icons.zoom_in),
        ),
        const SizedBox(height: 10),
        if (hourHeight > 40)
          FloatingActionButton(
            heroTag: 'zoomOut',
            mini: true,
            onPressed: onZoomOut,
            child: const Icon(Icons.zoom_out),
          ),
      ],
    );
  }
}
