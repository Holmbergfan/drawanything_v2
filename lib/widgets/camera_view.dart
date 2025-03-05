import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../providers/image_provider.dart';

class CameraView extends StatefulWidget {
  final CameraController? controller;

  const CameraView({super.key, required this.controller});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  Offset _startPosition = Offset.zero;
  Offset _lastPosition = Offset.zero;
  double _lastScale = 1.0;

  @override
  Widget build(BuildContext context) {
    if (widget.controller == null || !widget.controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    final screenSize = MediaQuery.of(context).size;
    final cameraAspectRatio = widget.controller!.value.aspectRatio;
    
    return Consumer<ImageOverlayProvider>(
      builder: (context, imageProvider, child) {
        final isManipulatingCamera = imageProvider.manipulationMode == ManipulationMode.camera;
        
        return Center(
          child: GestureDetector(
            onScaleStart: isManipulatingCamera ? (details) {
              _startPosition = details.localFocalPoint;
              _lastPosition = imageProvider.cameraPosition;
              _lastScale = imageProvider.cameraScale;
            } : null,
            onScaleUpdate: isManipulatingCamera ? (details) {
              // Handle movement
              final delta = details.localFocalPoint - _startPosition;
              final newPosition = Offset(
                _lastPosition.dx + delta.dx,
                _lastPosition.dy + delta.dy
              );
              
              // Allow more movement range based on scale
              final movementRange = screenSize.width * imageProvider.cameraScale;
              final adjustedPosition = Offset(
                newPosition.dx.clamp(-movementRange, movementRange),
                newPosition.dy.clamp(-movementRange, movementRange)
              );
              
              imageProvider.updateCameraPosition(adjustedPosition);
              
              // Handle scaling with wider range
              if (details.scale != 1.0) {
                final newScale = _lastScale * details.scale;
                // Allow scaling from 0.5 to 5.0
                imageProvider.updateCameraScale(newScale.clamp(0.5, 5.0));
              }
            } : null,
            onScaleEnd: isManipulatingCamera ? (details) {
              _lastPosition = imageProvider.cameraPosition;
              _lastScale = imageProvider.cameraScale;
            } : null,
            child: Container(
              width: screenSize.width,
              height: screenSize.height,
              color: Colors.white, // Changed from Colors.black
              child: Transform.translate(
                offset: imageProvider.cameraPosition,
                child: Transform.scale(
                  scale: imageProvider.cameraScale,
                  child: AspectRatio(
                    aspectRatio: cameraAspectRatio,
                    child: CameraPreview(widget.controller!),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
