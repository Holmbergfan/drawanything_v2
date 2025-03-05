// lib/widgets/image_overlay.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/image_provider.dart';
import '../models/overlay_image.dart';

class ImageOverlayWidget extends StatefulWidget {
  const ImageOverlayWidget({super.key});

  @override
  State<ImageOverlayWidget> createState() => _ImageOverlayWidgetState();
}

class _ImageOverlayWidgetState extends State<ImageOverlayWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ImageOverlayProvider>(
      builder: (context, provider, child) {
        final overlay = provider.currentOverlay;
        if (overlay == null) return const SizedBox.shrink();

        return Stack(
          children: [
            if (provider.showGrid) _buildGrid(provider.gridSize),
            _buildOverlayImage(overlay, provider),
          ],
        );
      },
    );
  }

  Widget _buildOverlayImage(OverlayImage overlay, ImageOverlayProvider provider) {
    return Positioned(
      left: overlay.position.dx,
      top: overlay.position.dy,
      child: GestureDetector(
        onScaleStart: (details) {
          _startPosition = overlay.position;
          _startRotation = overlay.rotation;
          _startScale = overlay.scale;
          _startFocalPoint = details.focalPoint;
        },
        onScaleUpdate: (details) {
          if (_startPosition == null || _startRotation == null || _startScale == null || _startFocalPoint == null) return;

          if (provider.manipulationMode == ManipulationMode.image) {
            // Handle position update
            final newPosition = Offset(
              _startPosition!.dx + (details.focalPoint.dx - _startFocalPoint!.dx),
              _startPosition!.dy + (details.focalPoint.dy - _startFocalPoint!.dy),
            );
            provider.updatePosition(newPosition);
            
            // Handle scale and rotation
            if (details.scale != 1.0) {
              provider.updateScaleDirectly(_startScale! * details.scale);
            }
            if (details.rotation != 0.0) {
              provider.updateRotationDirectly(_startRotation! + details.rotation);
            }
          } else {
            // Camera mode
            final newPosition = Offset(
              provider.cameraPosition.dx + (details.focalPoint.dx - _startFocalPoint!.dx),
              provider.cameraPosition.dy + (details.focalPoint.dy - _startFocalPoint!.dy),
            );
            provider.updateCameraPosition(newPosition);
            
            if (details.scale != 1.0) {
              provider.updateCameraScale(provider.cameraScale * details.scale);
            }
          }
        },
        child: Transform(
          transform: _buildTransformMatrix(overlay),
          alignment: Alignment.center,
          child: Opacity(
            opacity: overlay.opacity,
            child: _buildFilteredImage(overlay),
          ),
        ),
      ),
    );
  }

  Widget _buildFilteredImage(OverlayImage overlay) {
    final image = Image.file(
      overlay.imageFile,
      fit: BoxFit.contain,
    );

    if (overlay.filter == null) return image;

    // Apply selected filter
    switch (overlay.filter) {
      case 'grayscale':
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0, 0, 0, 1, 0,
          ]),
          child: image,
        );
      case 'sepia':
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.393, 0.769, 0.189, 0, 0,
            0.349, 0.686, 0.168, 0, 0,
            0.272, 0.534, 0.131, 0, 0,
            0, 0, 0, 1, 0,
          ]),
          child: image,
        );
      case 'invert':
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            -1, 0, 0, 0, 255,
            0, -1, 0, 0, 255,
            0, 0, -1, 0, 255,
            0, 0, 0, 1, 0,
          ]),
          child: image,
        );
      default:
        return image;
    }
  }

  Matrix4 _buildTransformMatrix(OverlayImage overlay) {
    final matrix = Matrix4.identity()
      ..scale(overlay.scale * (overlay.isFlippedHorizontally ? -1.0 : 1.0),
              overlay.scale * (overlay.isFlippedVertically ? -1.0 : 1.0))
      ..rotateZ(overlay.rotation);
    return matrix;
  }

  Widget _buildGrid(double gridSize) {
    return CustomPaint(
      painter: GridPainter(gridSize: gridSize),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Offset? _startPosition;
  double? _startRotation;
  double? _startScale;
  Offset? _startFocalPoint; // Added this field to track the initial focal point
}

class GridPainter extends CustomPainter {
  final double gridSize;
  final Paint _paint;

  GridPainter({required this.gridSize})
      : _paint = Paint()
          ..color = Colors.grey.withAlpha(128)  // 0.5 opacity = 128 in alpha value (0-255)
          ..strokeWidth = 0.5;

  @override
  void paint(Canvas canvas, Size size) {
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        _paint,
      );
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        _paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => gridSize != oldDelegate.gridSize;
}



