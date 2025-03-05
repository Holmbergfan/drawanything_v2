// lib/widgets/grid_overlay.dart
import 'package:flutter/material.dart';

class GridOverlay extends StatelessWidget {
  final double size;
  
  const GridOverlay({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridPainter(size: size),
      child: Container(),
    );
  }
}

class GridPainter extends CustomPainter {
  final double size;
  
  GridPainter({required this.size});
  
  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(128) // 50% opacity
      ..strokeWidth = 0.5;
      
    // Draw horizontal lines
    for (double y = 0; y < canvasSize.height; y += size) {
      canvas.drawLine(Offset(0, y), Offset(canvasSize.width, y), paint);
    }
    
    // Draw vertical lines
    for (double x = 0; x < canvasSize.width; x += size) {
      canvas.drawLine(Offset(x, 0), Offset(x, canvasSize.height), paint);
    }
    
    // Draw a center cross with a different color
    final centerPaint = Paint()
      ..color = Colors.red.withAlpha(204) // 80% opacity
      ..strokeWidth = 1.0;
    
    final centerX = canvasSize.width / 2;
    final centerY = canvasSize.height / 2;
    
    // Horizontal center line
    canvas.drawLine(
      Offset(0, centerY),
      Offset(canvasSize.width, centerY),
      centerPaint,
    );
    
    // Vertical center line
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, canvasSize.height),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is GridPainter) {
      return oldDelegate.size != size;
    }
    return true;
  }
}