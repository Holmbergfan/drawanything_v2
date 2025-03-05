import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../models/overlay_image.dart';
import '../models/project.dart';
import 'package:logging/logging.dart';

final _logger = Logger('ImageProvider');

enum ManipulationMode {
  image,  // Manipulate the reference image
  camera  // Manipulate the camera view
}

class ImageOverlayProvider extends ChangeNotifier {
  OverlayImage? _currentOverlay;
  final List<Project> _savedProjects = [];
  bool _showGrid = false;
  double _gridSize = 50.0;
  bool _isControlPanelVisible = true;
  ManipulationMode _manipulationMode = ManipulationMode.image;
  
  // Camera view transformation properties
  Offset _cameraPosition = Offset.zero;
  double _cameraScale = 1.0;
  double _cameraRotation = 0.0;
  
  // Boundary constants to prevent losing the view
  static const double _maxCameraDistance = 300.0;  // Maximum distance from center
  static const double _movementDamping = 0.4;      // Movement reduction factor
  
  // Getters
  OverlayImage? get currentOverlay => _currentOverlay;
  List<Project> get savedProjects => List.unmodifiable(_savedProjects);
  bool get showGrid => _showGrid;
  double get gridSize => _gridSize;
  bool get isControlPanelVisible => _isControlPanelVisible;
  ManipulationMode get manipulationMode => _manipulationMode;
  Offset get cameraPosition => _cameraPosition;
  double get cameraScale => _cameraScale;
  double get cameraRotation => _cameraRotation;

  void toggleManipulationMode() {
    _manipulationMode = (_manipulationMode == ManipulationMode.image) 
        ? ManipulationMode.camera 
        : ManipulationMode.image;
    notifyListeners();
  }

  void updateCameraPosition(Offset newPosition) {
    if (_manipulationMode != ManipulationMode.camera) return;
    
    // Update camera position only
    _cameraPosition = newPosition;
    notifyListeners();
  }

  void updateCameraScale(double newScale) {
    if (_manipulationMode != ManipulationMode.camera) return;
    
    // Apply strict limits to scale
    const double minScale = 0.2;
    const double maxScale = 3.0;
    
    // Enforce smaller scale range for better usability
    _cameraScale = newScale.clamp(minScale, maxScale);
    notifyListeners();
  }

  void updateCameraRotation(double newRotation) {
    // Camera rotation is disabled by design
    if (_cameraRotation != 0.0) {
      _cameraRotation = 0.0;
      notifyListeners();
    }
  }

  void resetCameraTransformations() {
    bool shouldNotify = false;
    
    if (_cameraPosition != Offset.zero) {
      _cameraPosition = Offset.zero;
      shouldNotify = true;
    }
    
    if (_cameraScale != 1.0) {
      _cameraScale = 1.0;
      shouldNotify = true;
    }
    
    if (_cameraRotation != 0.0) {
      _cameraRotation = 0.0;
      shouldNotify = true;
    }
    
    // Reset image to center with default scale when camera is reset
    if (_currentOverlay != null) {
      _currentOverlay = _currentOverlay!.copyWith(
        position: Offset.zero,
        scale: 0.3,
        rotation: 0.0
      );
      shouldNotify = true;
    }
    
    if (shouldNotify) {
      notifyListeners();
    }
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = path.basename(image.path);
        final savedPath = path.join(appDir.path, 'images', fileName);
        
        await Directory(path.join(appDir.path, 'images')).create(recursive: true);
        
        final File imageFile = File(image.path);
        final File savedFile = await imageFile.copy(savedPath);
        
        // Center the image initially
        _currentOverlay = OverlayImage(
          path: savedPath,
          imageFile: savedFile,
          position: Offset.zero,  // This will be center since we're using Transform.translate
          scale: 0.3,  // Initial scale
        );
        
        // Reset camera position when loading a new image
        resetCameraTransformations();
        
        notifyListeners();
      }
    } catch (e) {
      _logger.severe('Error picking image: $e');
      rethrow;
    }
  }

  void updateOpacity(double value) {
    if (_currentOverlay != null && value != _currentOverlay!.opacity) {
      _currentOverlay = _currentOverlay!.copyWith(opacity: value.clamp(0.0, 1.0));
      notifyListeners();
    }
  }

  void updatePosition(Offset newPosition) {
    if (_manipulationMode != ManipulationMode.image || _currentOverlay == null) return;
    
    _currentOverlay = _currentOverlay!.copyWith(position: newPosition);
    notifyListeners();
  }

  void updateScale(double scaleFactor) {
    if (_manipulationMode != ManipulationMode.image || _currentOverlay == null) return;
    
    final newScale = (_currentOverlay!.scale * scaleFactor).clamp(0.1, 5.0);
    if (newScale != _currentOverlay!.scale) {
      _currentOverlay = _currentOverlay!.copyWith(scale: newScale);
      notifyListeners();
    }
  }

  void updateScaleDirectly(double newScale) {
    if (_manipulationMode != ManipulationMode.image || _currentOverlay == null) return;
    
    if (newScale != _currentOverlay!.scale) {
      _currentOverlay = _currentOverlay!.copyWith(scale: newScale.clamp(0.1, 5.0));
      notifyListeners();
    }
  }

  void updateRotation(double angleDelta) {
    if (_currentOverlay != null) {
      final newRotation = _currentOverlay!.rotation + angleDelta;
      if (newRotation != _currentOverlay!.rotation) {
        _currentOverlay = _currentOverlay!.copyWith(rotation: newRotation);
        notifyListeners();
      }
    }
  }

  void updateRotationDirectly(double newRotation) {
    if (_manipulationMode != ManipulationMode.image || _currentOverlay == null) return;
    
    if (newRotation != _currentOverlay!.rotation) {
      _currentOverlay = _currentOverlay!.copyWith(rotation: newRotation);
      notifyListeners();
    }
  }

  void flipHorizontally() {
    if (_currentOverlay != null) {
      _currentOverlay = _currentOverlay!.copyWith(
        isFlippedHorizontally: !_currentOverlay!.isFlippedHorizontally,
      );
      notifyListeners();
    }
  }

  void flipVertically() {
    if (_currentOverlay != null) {
      _currentOverlay = _currentOverlay!.copyWith(
        isFlippedVertically: !_currentOverlay!.isFlippedVertically,
      );
      notifyListeners();
    }
  }

  void applyFilter(String? filter) {
    if (_currentOverlay != null) {
      final newFilter = (_currentOverlay!.filter == filter) ? null : filter;
      if (newFilter != _currentOverlay!.filter) {
        _currentOverlay = _currentOverlay!.copyWith(filter: newFilter);
        notifyListeners();
      }
    }
  }

  void resetTransformations() {
    // Always reset camera position
    resetCameraTransformations();
    
    // If manipulating image, reset the image too
    if (_manipulationMode == ManipulationMode.image && _currentOverlay != null) {
      _currentOverlay = _currentOverlay!.reset();
      notifyListeners();
    }
  }

  void toggleGrid() {
    _showGrid = !_showGrid;
    notifyListeners();
  }

  void updateGridSize(double size) {
    if (size != _gridSize) {
      _gridSize = size.clamp(10.0, 200.0);
      notifyListeners();
    }
  }

  void toggleControlPanel() {
    _isControlPanelVisible = !_isControlPanelVisible;
    notifyListeners();
  }

  Future<void> saveProject(String name) async {
    if (_currentOverlay == null) return;
    
    try {
      final project = Project(
        name: name,
        date: DateTime.now(),
        overlayImage: _currentOverlay!,
      );
      
      _savedProjects.add(project);
      await _saveProjectsToPrefs();
      notifyListeners();
    } catch (e) {
      _logger.severe('Error saving project: $e');
      rethrow;
    }
  }

  Future<void> loadProject(Project project) async {
    try {
      final overlayImage = project.overlayImage;
      final file = File(overlayImage.path);
      
      if (await file.exists()) {
        _currentOverlay = overlayImage.copyWith();
        
        // Reset camera position when loading a project
        _cameraPosition = Offset.zero;
        _cameraScale = 1.0;
        _cameraRotation = 0.0;
        
        notifyListeners();
      } else {
        _logger.warning('Image file not found: ${overlayImage.path}');
        throw FileSystemException('Image file not found', overlayImage.path);
      }
    } catch (e) {
      _logger.severe('Error loading project: $e');
      rethrow;
    }
  }

  Future<void> loadProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectsJson = prefs.getStringList('projects') ?? [];
      
      _savedProjects.clear();
      for (final projectJson in projectsJson) {
        final Map<String, dynamic> projectMap = jsonDecode(projectJson);
        _savedProjects.add(Project.fromJson(projectMap));
      }
      
      notifyListeners();
    } catch (e) {
      _logger.severe('Error loading projects: $e');
      rethrow;
    }
  }

  Future<void> _saveProjectsToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectsJson = _savedProjects.map((p) => jsonEncode(p.toJson())).toList();
      await prefs.setStringList('projects', projectsJson);
    } catch (e) {
      _logger.severe('Error saving projects to preferences: $e');
      rethrow;
    }
  }

  Future<void> deleteProject(Project project) async {
    try {
      _savedProjects.remove(project);
      await _saveProjectsToPrefs();
      notifyListeners();
    } catch (e) {
      _logger.severe('Error deleting project: $e');
      rethrow;
    }
  }

  Future<String?> exportScreenshot(BuildContext context) async {
    // Capture the boundary synchronously before any async operations
    final RenderRepaintBoundary? boundary = 
        context.findRenderObject() as RenderRepaintBoundary?;
    
    if (boundary == null) {
      _logger.warning('Failed to capture screenshot: Boundary is null');
      return null;
    }

    try {
      // Get the application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'screenshot_$timestamp.jpg';
      final savedPath = path.join(appDir.path, 'screenshots', fileName);
      
      // Create screenshots directory if it doesn't exist
      await Directory(path.join(appDir.path, 'screenshots')).create(recursive: true);
      
      // Use RenderRepaintBoundary to capture the screen
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        final buffer = byteData.buffer.asUint8List();
        final file = File(savedPath);
        await file.writeAsBytes(buffer);
        return savedPath;
      }
      
      _logger.warning('Failed to capture screenshot: ByteData is null');
      return null;
    } catch (e) {
      _logger.severe('Error capturing screenshot: $e');
      return null;
    }
  }
}
