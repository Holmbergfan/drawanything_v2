import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraProvider extends ChangeNotifier {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isPermissionGranted = false;
  bool _isFrontCamera = false;
  bool _isFlashlightOn = false;
  bool _isDisposed = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isPermissionGranted => _isPermissionGranted;
  bool get isFrontCamera => _isFrontCamera;
  bool get isFlashlightOn => _isFlashlightOn;

  Future<void> initialize() async {
    // Request camera permission
    final status = await Permission.camera.request();
    _isPermissionGranted = status.isGranted;
    
    if (!_isPermissionGranted) {
      _safeNotifyListeners();
      return;
    }

    // Get available cameras
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    // Initialize with the first (back) camera
    await _initializeCamera();
    
    _safeNotifyListeners();
  }

  Future<void> _initializeCamera() async {
    if (_cameras.isEmpty) return;

    // Get camera based on current selection (front or back)
    final cameraIndex = _isFrontCamera ? 1 : 0;
    
    // Check if camera index is valid before accessing it
    final validIndex = _cameras.length > cameraIndex ? cameraIndex : 0;
    if (validIndex >= _cameras.length) return;
    
    final cameraDescription = _cameras[validIndex];

    // Dispose previous controller if it exists
    if (_controller != null) {
      await _controller!.dispose();
    }

    // Create a new controller
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium, // Lower resolution preset to avoid extreme aspect ratios
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg, // Use JPEG format for better compatibility
    );

    // Initialize the controller
    try {
      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      _isInitialized = false;
    }
  }
  
  void toggleCamera() async {
    // Prevent calls after disposal
    if (_isDisposed) return;
    
    _isFrontCamera = !_isFrontCamera;
    await _initializeCamera();
    _safeNotifyListeners();
  }

  void toggleFlashlight() async {
    // Prevent calls after disposal
    if (_isDisposed) return;
    
    // Check for null controller or uninitialized state
    if (_controller == null || !_isInitialized) return;
    
    try {
      if (_isFlashlightOn) {
        await _controller!.setFlashMode(FlashMode.off);
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
      }
      
      _isFlashlightOn = !_isFlashlightOn;
      _safeNotifyListeners();
    } catch (e) {
      debugPrint('Error toggling flashlight: $e');
    }
  }
  
  // Safe wrapper around notifyListeners that checks for disposal state
  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (_controller != null) {
      _controller!.dispose();
      _controller = null;
    }
    super.dispose();
  }
}