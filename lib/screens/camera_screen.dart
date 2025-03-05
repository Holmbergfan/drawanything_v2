import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/camera_provider.dart';
import '../providers/image_provider.dart';
import '../widgets/camera_view.dart';
import '../widgets/image_overlay.dart';
import '../widgets/control_panel.dart';
import '../widgets/grid_overlay.dart';
import 'gallery_screen.dart';
import 'settings_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Store provider references before the async gap
    final cameraProvider = context.read<CameraProvider>();
    final imageProvider = context.read<ImageOverlayProvider>();
    
    // Initialize camera when the screen loads
    Future.microtask(() {
      if (!mounted) return; // Guard with mounted check
      
      cameraProvider.initialize();
      imageProvider.loadProjects();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Don't directly call dispose on the provider (it's already taken care of by the widget tree)
    // Instead, just reinitialize when the app is resumed from background
    if (state == AppLifecycleState.resumed) {
      // When app comes to foreground, reinitialize the camera
      if (mounted) {
        // Store provider reference to avoid BuildContext across async gaps
        final cameraProvider = context.read<CameraProvider>();
        // Use async/await pattern
        Future.microtask(() async {
          await cameraProvider.initialize();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    return Consumer2<CameraProvider, ImageOverlayProvider>(
      builder: (context, cameraProvider, imageProvider, child) {
        if (!cameraProvider.isPermissionGranted) {
          return _buildPermissionDeniedView();
        }

        if (!cameraProvider.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            // Camera view - pass controller without force unwrapping
            CameraView(controller: cameraProvider.controller),
            
            // Grid overlay (if enabled)
            if (imageProvider.showGrid)
              GridOverlay(size: imageProvider.gridSize),
            
            // Image overlay
            if (imageProvider.currentOverlay != null)
              ImageOverlayWidget(),
            
            // Debug info
            Positioned(
              top: 60,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black.withAlpha(128),
                child: Text(
                  'Mode: ${imageProvider.manipulationMode == ManipulationMode.image ? "Image" : "Camera"}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            
            // Control panel
            if (imageProvider.isControlPanelVisible)
              const ControlPanel(),
            
            // App bar with minimal controls
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildAppBar(cameraProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppBar(CameraProvider cameraProvider) {
    return SafeArea(
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        color: Colors.black54,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.photo_library, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GalleryScreen()),
                );
              },
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    cameraProvider.isFlashlightOn 
                        ? Icons.flash_on 
                        : Icons.flash_off,
                    color: Colors.white,
                  ),
                  onPressed: cameraProvider.toggleFlashlight,
                ),
                IconButton(
                  icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                  onPressed: cameraProvider.toggleCamera,
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionDeniedView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.camera_alt, size: 100, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Camera permission is required',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final cameraProvider = context.read<CameraProvider>();
              cameraProvider.initialize();
            },
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<ImageOverlayProvider>(
      builder: (context, imageProvider, child) {
        // If no overlay image is selected yet, show button to pick an image
        if (imageProvider.currentOverlay == null) {
          return FloatingActionButton(
            onPressed: () async {
              await imageProvider.pickImage();
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.add_photo_alternate),
          );
        }
        
        // Otherwise, show button to toggle control panel
        return FloatingActionButton(
          onPressed: imageProvider.toggleControlPanel,
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(
            imageProvider.isControlPanelVisible
                ? Icons.visibility_off
                : Icons.visibility,
          ),
        );
      },
    );
  }
}
