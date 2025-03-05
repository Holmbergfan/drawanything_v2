import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/camera_provider.dart';
import 'providers/image_provider.dart';
import 'screens/camera_screen.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Request permissions on app start
  await [
    Permission.camera,
    Permission.storage,
  ].request();
  
  runApp(const DrawAnythingApp());
}

class DrawAnythingApp extends StatelessWidget {
  const DrawAnythingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CameraProvider()),
        ChangeNotifierProvider(create: (_) => ImageOverlayProvider()),
      ],
      child: MaterialApp(
        title: 'Draw Anything',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // Dark theme for better contrast with camera view
          brightness: Brightness.dark,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            elevation: 0,
          ),
          // Make controls more visible on camera background
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
            ),
          ),
        ),
        home: _buildOnboarding(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  Widget _buildOnboarding() {
    return FutureBuilder<bool>(
      // Check if first launch
      future: _isFirstLaunch(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // If first launch, show onboarding
        if (snapshot.data == true) {
          return OnboardingScreen();
        }
        
        // Otherwise go straight to main screen
        return const CameraScreen();
      },
    );
  }

  Future<bool> _isFirstLaunch() async {
    // In a real app, you would use shared_preferences to check
    // For this example, return true to always show onboarding
    return true;
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Welcome to Draw Anything',
      'description': 'The app that helps you draw anything with precision.',
      'icon': Icons.brush,
    },
    {
      'title': 'Camera Overlay',
      'description': 'Position your reference image over the camera view.',
      'icon': Icons.camera_alt,
    },
    {
      'title': 'Adjust and Transform',
      'description': 'Resize, rotate, and adjust opacity to match your needs.',
      'icon': Icons.tune,
    },
    {
      'title': 'Save Your Projects',
      'description': 'Save your work and come back to it later.',
      'icon': Icons.save,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(
                    _pages[index]['title'],
                    _pages[index]['description'],
                    _pages[index]['icon'],
                  );
                },
              ),
            ),
            _buildPageIndicator(),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Theme.of(context).primaryColor
                : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _currentPage > 0
              ? TextButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text('Back'),
                )
              : const SizedBox(width: 80),
          _currentPage < _pages.length - 1
              ? TextButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text('Next'),
                )
              : ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const CameraScreen()),
                    );
                  },
                  child: const Text('Get Started'),
                ),
        ],
      ),
    );
  }
}
