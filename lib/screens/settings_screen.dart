import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _saveImageWithProject = true;
  bool _highQualityCamera = true;
  bool _showGridByDefault = false;
  double _defaultOpacity = 0.5;
  bool _enableAccessibilityFeatures = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _saveImageWithProject = prefs.getBool('saveImageWithProject') ?? true;
      _highQualityCamera = prefs.getBool('highQualityCamera') ?? true;
      _showGridByDefault = prefs.getBool('showGridByDefault') ?? false;
      _defaultOpacity = prefs.getDouble('defaultOpacity') ?? 0.5;
      _enableAccessibilityFeatures = prefs.getBool('enableAccessibilityFeatures') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    // Store context before async gap
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('saveImageWithProject', _saveImageWithProject);
    await prefs.setBool('highQualityCamera', _highQualityCamera);
    await prefs.setBool('showGridByDefault', _showGridByDefault);
    await prefs.setDouble('defaultOpacity', _defaultOpacity);
    await prefs.setBool('enableAccessibilityFeatures', _enableAccessibilityFeatures);
    
    // Check if widget is still mounted before showing SnackBar
    if (!mounted) return;
    
    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'General Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSwitchTile(
                  title: 'Save Image with Project',
                  subtitle: 'Store a copy of images with saved projects',
                  value: _saveImageWithProject,
                  onChanged: (value) {
                    setState(() => _saveImageWithProject = value);
                  },
                ),
                _buildSwitchTile(
                  title: 'High Quality Camera',
                  subtitle: 'Use highest camera resolution (may affect performance)',
                  value: _highQualityCamera,
                  onChanged: (value) {
                    setState(() => _highQualityCamera = value);
                  },
                ),
                _buildSwitchTile(
                  title: 'Show Grid by Default',
                  subtitle: 'Display grid when opening the app',
                  value: _showGridByDefault,
                  onChanged: (value) {
                    setState(() => _showGridByDefault = value);
                  },
                ),
                
                const Divider(),
                
                const Text(
                  'Default Values',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSliderTile(
                  title: 'Default Opacity',
                  value: _defaultOpacity,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  label: '${(_defaultOpacity * 100).round()}%',
                  onChanged: (value) {
                    setState(() => _defaultOpacity = value);
                  },
                ),
                
                const Divider(),
                
                const Text(
                  'Accessibility',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSwitchTile(
                  title: 'Enhanced Accessibility',
                  subtitle: 'Improve screen reader support and touch targets',
                  value: _enableAccessibilityFeatures,
                  onChanged: (value) {
                    setState(() => _enableAccessibilityFeatures = value);
                  },
                ),
                
                const Divider(),
                
                const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Version'),
                  subtitle: const Text('1.0.0'),
                  trailing: const Icon(Icons.info_outline),
                  onTap: () {
                    // Show app info or changelog
                  },
                ),
                
                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Save Settings'),
                ),
                
                const SizedBox(height: 16),
                
                TextButton(
                  onPressed: () {
                    // Show tutorial again
                  },
                  child: const Text('Show App Tutorial'),
                ),
              ],
            ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSliderTile({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                label: label,
                onChanged: onChanged,
              ),
            ),
            Container(
              width: 50,
              alignment: Alignment.center,
              child: Text(label),
            ),
          ],
        ),
      ],
    );
  }
}
