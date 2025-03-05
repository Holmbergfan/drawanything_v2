import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/image_provider.dart';
import '../models/project.dart';
import 'camera_screen.dart';
import 'package:intl/intl.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Consumer<ImageOverlayProvider>(
        builder: (context, provider, child) {
          final projects = provider.savedProjects;
          
          if (projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No projects yet'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _startNewProject(context),
                    child: const Text('Create New Project'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: projects.length + 1, // +1 for "New Project" card
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildNewProjectCard(context);
              }
              
              final project = projects[index - 1];
              return _buildProjectCard(context, project);
            },
          );
        },
      ),
    );
  }

  Widget _buildNewProjectCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _startNewProject(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_circle_outline, size: 48),
            SizedBox(height: 16),
            Text('New Project'),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project) {
    final file = File(project.overlayImage.path);
    
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _openProject(context, project),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
                child: file.existsSync()
                    ? Image.file(
                        file,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.broken_image, size: 48),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatDate(project.date),
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  void _startNewProject(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );
  }

  void _openProject(BuildContext context, Project project) {
    final provider = context.read<ImageOverlayProvider>();
    provider.loadProject(project);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );
  }
}
