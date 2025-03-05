import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/image_provider.dart';





class ControlPanel extends StatefulWidget {

  const ControlPanel({super.key});



  @override

  State<ControlPanel> createState() => _ControlPanelState();

}



class _ControlPanelState extends State<ControlPanel> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  final TextEditingController _projectNameController = TextEditingController();



  @override

  void initState() {

    super.initState();

    _tabController = TabController(length: 3, vsync: this);

  }



  @override

  void dispose() {

    _tabController.dispose();

    _projectNameController.dispose();

    super.dispose();

  }



  @override

  Widget build(BuildContext context) {

    return Consumer<ImageOverlayProvider>(

      builder: (context, imageProvider, child) {

        if (imageProvider.currentOverlay == null) {

          return const SizedBox.shrink(); // Don't show control panel if no image

        }



        return Positioned(

          bottom: 0,

          left: 0,

          right: 0,

          child: Container(

            color: Colors.black87,

            child: SafeArea(

              top: false,

              child: Column(

                mainAxisSize: MainAxisSize.min,

                children: [

                  TabBar(

                    controller: _tabController,

                    indicatorColor: Theme.of(context).primaryColor,

                    tabs: const [

                      Tab(icon: Icon(Icons.tune), text: 'Adjust'),

                      Tab(icon: Icon(Icons.filter), text: 'Filters'),

                      Tab(icon: Icon(Icons.save), text: 'Save'),

                    ],

                  ),

                  SizedBox(

                    height: 150, // Reduced height to avoid overflow

                    child: TabBarView(

                      controller: _tabController,

                      children: [

                        _buildAdjustTab(imageProvider),

                        _buildFiltersTab(imageProvider),

                        _buildSaveTab(imageProvider),

                      ],

                    ),

                  ),

                ],

              ),

            ),

          ),

        );

      },

    );

  }



  Widget _buildAdjustTab(ImageOverlayProvider imageProvider) {

    final overlay = imageProvider.currentOverlay!;

    

    return SingleChildScrollView(

      child: Padding(

        padding: const EdgeInsets.all(12.0),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          mainAxisSize: MainAxisSize.min,

          children: [

            // Opacity slider

            const Text('Opacity', style: TextStyle(color: Colors.white, fontSize: 12)),

            Slider(

              value: overlay.opacity,

              min: 0.1,

              max: 1.0,

              onChanged: imageProvider.updateOpacity,

            ),



            // Mode selector (Image/Camera)

            Container(

              width: double.infinity,

              padding: EdgeInsets.symmetric(vertical: 6),

              decoration: BoxDecoration(

                color: Colors.black45,

                borderRadius: BorderRadius.circular(6)

              ),

              child: Row(

                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  Text('Manipulate:', style: TextStyle(color: Colors.white, fontSize: 12)),

                  SizedBox(width: 8),

                  ToggleButtons(

                    constraints: BoxConstraints(minWidth: 80, minHeight: 30),

                    isSelected: [

                      imageProvider.manipulationMode == ManipulationMode.image, 

                      imageProvider.manipulationMode == ManipulationMode.camera

                    ],

                    onPressed: (index) {

                      if (index == 0) {

                        imageProvider.toggleManipulationMode();

                      } else {

                        imageProvider.toggleManipulationMode();

                      }

                    },

                    borderRadius: BorderRadius.circular(6),

                    children: [

                      Row(

                        mainAxisSize: MainAxisSize.min,

                        children: [

                          Icon(Icons.image, size: 16, color: Colors.white),

                          SizedBox(width: 4),

                          Text('Image', style: TextStyle(fontSize: 11, color: Colors.white))

                        ],

                      ),

                      Row(

                        mainAxisSize: MainAxisSize.min,

                        children: [

                          Icon(Icons.camera_alt, size: 16, color: Colors.white),

                          SizedBox(width: 4),

                          Text('Camera', style: TextStyle(fontSize: 11, color: Colors.white))

                        ],

                      ),

                    ],

                  ),

                ],

              ),

            ),

            

            const SizedBox(height: 8),

            

            // Transform controls - only show when manipulating image

            if (imageProvider.manipulationMode == ManipulationMode.image)

              Row(

                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [

                  // Flip section

                  Container(

                    decoration: BoxDecoration(

                      border: Border.all(color: Colors.white24),

                      borderRadius: BorderRadius.circular(8),

                    ),

                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

                    child: Row(

                      mainAxisSize: MainAxisSize.min,

                      children: [

                        Text('Flip:', style: TextStyle(color: Colors.white, fontSize: 12)),

                        IconButton(

                          icon: Icon(Icons.flip, size: 18),

                          color: overlay.isFlippedHorizontally ? Theme.of(context).primaryColor : Colors.white,

                          constraints: BoxConstraints(minWidth: 30, minHeight: 36),

                          padding: EdgeInsets.all(4),

                          onPressed: imageProvider.flipHorizontally,

                          tooltip: 'Horizontal',

                        ),

                        IconButton(

                          icon: Icon(Icons.flip_camera_android, size: 18),

                          color: overlay.isFlippedVertically ? Theme.of(context).primaryColor : Colors.white,

                          constraints: BoxConstraints(minWidth: 30, minHeight: 36),

                          padding: EdgeInsets.all(4),

                          onPressed: imageProvider.flipVertically,

                          tooltip: 'Vertical',

                        ),

                      ],

                    ),

                  ),

                ],

              ),

            

            const SizedBox(height: 8),

            

            // Grid and reset controls

            Row(

              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [

                // Grid toggle

                ElevatedButton.icon(

                  icon: Icon(Icons.grid_on, size: 16),

                  label: Text('Grid', style: TextStyle(fontSize: 11)),

                  onPressed: imageProvider.toggleGrid,

                  style: ElevatedButton.styleFrom(

                    backgroundColor: imageProvider.showGrid ? Theme.of(context).primaryColor : Colors.grey[800],

                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),

                  ),

                ),

                // Reset button

                ElevatedButton.icon(

                  icon: Icon(Icons.refresh, size: 16),

                  label: Text('Reset', style: TextStyle(fontSize: 11)),

                  onPressed: imageProvider.resetTransformations,

                  style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.grey[800],

                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),

                  ),

                ),

              ],

            ),

          ],

        ),

      ),

    );

  }



  Widget _buildFiltersTab(ImageOverlayProvider imageProvider) {

    final currentFilter = imageProvider.currentOverlay?.filter;

    

    return SingleChildScrollView(

      child: Padding(

        padding: const EdgeInsets.all(12.0),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          mainAxisSize: MainAxisSize.min,

          children: [

            const Text('Image Filters', style: TextStyle(color: Colors.white, fontSize: 12)),

            const SizedBox(height: 12),

            SizedBox(

              height: 70,

              child: ListView(

                scrollDirection: Axis.horizontal,

                children: [

                  _filterOption(

                    label: 'Normal',

                    onTap: () => imageProvider.applyFilter(null),

                    isSelected: currentFilter == null,

                  ),

                  _filterOption(

                    label: 'Grayscale',

                    onTap: () => imageProvider.applyFilter('grayscale'),

                    isSelected: currentFilter == 'grayscale',

                  ),

                  _filterOption(

                    label: 'High Contrast',

                    onTap: () => imageProvider.applyFilter('highContrast'),

                    isSelected: currentFilter == 'highContrast',

                  ),

                  _filterOption(

                    label: 'Invert',

                    onTap: () => imageProvider.applyFilter('invertColors'),

                    isSelected: currentFilter == 'invertColors',

                  ),

                ],

              ),

            ),

            

            const SizedBox(height: 8),

            const Text('Grid Size', style: TextStyle(color: Colors.white, fontSize: 12)),

            Slider(

              value: imageProvider.gridSize,

              min: 20,

              max: 100,

              divisions: 8,

              label: '${imageProvider.gridSize.round()}',

              onChanged: (value) {

                imageProvider.updateGridSize(value);

              },

            ),

          ],

        ),

      ),

    );

  }



  Widget _buildSaveTab(ImageOverlayProvider imageProvider) {

    return SingleChildScrollView(

      child: Padding(

        padding: const EdgeInsets.all(12.0),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          mainAxisSize: MainAxisSize.min,

          children: [

            const Text('Save Project', style: TextStyle(color: Colors.white, fontSize: 12)),

            const SizedBox(height: 8),

            

            // Project name input

            TextField(

              controller: _projectNameController,

              decoration: const InputDecoration(

                hintText: 'Project Name',

                hintStyle: TextStyle(color: Colors.white60),

                enabledBorder: UnderlineInputBorder(

                  borderSide: BorderSide(color: Colors.white60),

                ),

              ),

              style: const TextStyle(color: Colors.white),

            ),

            

            const SizedBox(height: 16),

            

            // Save and export buttons

            Row(

              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [

                ElevatedButton.icon(

                  onPressed: () {

                    if (_projectNameController.text.isNotEmpty) {

                      imageProvider.saveProject(_projectNameController.text);

                      ScaffoldMessenger.of(context).showSnackBar(

                        const SnackBar(content: Text('Project saved')),

                      );

                      _projectNameController.clear();

                    } else {

                      ScaffoldMessenger.of(context).showSnackBar(

                        const SnackBar(content: Text('Please enter a project name')),

                      );

                    }

                  },

                  icon: const Icon(Icons.save, size: 16),

                  label: const Text('Save'),

                  style: ElevatedButton.styleFrom(

                    backgroundColor: Theme.of(context).primaryColor,

                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                  ),

                ),

                ElevatedButton.icon(

                  onPressed: () {

                    ScaffoldMessenger.of(context).showSnackBar(

                      const SnackBar(content: Text('Export feature coming soon')),

                    );

                  },

                  icon: const Icon(Icons.photo_camera, size: 16),

                  label: const Text('Export'),

                  style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.grey[800],

                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                  ),

                ),

              ],

            ),

          ],

        ),

      ),

    );

  }



  Widget _filterOption({

    required String label,

    required VoidCallback onTap,

    required bool isSelected,

  }) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        margin: const EdgeInsets.symmetric(horizontal: 8),

        padding: const EdgeInsets.all(8),

        decoration: BoxDecoration(

          border: Border.all(

            color: isSelected ? Theme.of(context).primaryColor : Colors.white30,

            width: 2,

          ),

          borderRadius: BorderRadius.circular(8),

        ),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            Icon(

              Icons.photo_filter,

              color: isSelected ? Theme.of(context).primaryColor : Colors.white,

              size: 18,

            ),

            const SizedBox(height: 4),

            Text(

              label,

              style: TextStyle(

                color: isSelected ? Theme.of(context).primaryColor : Colors.white,

                fontSize: 11,

              ),

            ),

          ],

        ),

      ),

    );

  }

}
