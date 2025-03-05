import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/image_provider.dart';
import '../models/project.dart';
import 'package:intl/intl.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: () async {
              // Import image directly from here
              final provider = context.read<ImageOverlayProvider>();
              await provider.pickImage();
              // Using mounted check to address async gap warning
              if (!context.mounted) return;
              if (provider.currentOverlay != null) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Consumer<ImageOverlayProvider>(
        builder: (context, provider, child) {
          if (provider.savedProjects.isEmpty) {
            return _buildEmptyState(context, provider);
          }
          
          return _buildProjectList(context, provider);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ImageOverlayProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.photo_album, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No saved projects',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your saved projects will appear here',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Import Image'),
            onPressed: () async {
              await provider.pickImage();
              // Using mounted check to address async gap warning
              if (!context.mounted) return;
              if (provider.currentOverlay != null) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProjectList(BuildContext context, ImageOverlayProvider provider) {
    final projects = provider.savedProjects;
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        final file = File(project.overlayImage.path);
        final exists = file.existsSync();
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project image preview
              exists
                  ? Image.file(
                      file,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                      ),
                    ),
              
              // Project info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(project.date),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              
              // Action buttons - wrapped in Padding since OverflowBar doesn't have padding parameter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: OverflowBar(
                  alignment: MainAxisAlignment.end,
                  spacing: 8,
                  overflowAlignment: OverflowBarAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      onPressed: () {
                        _confirmDelete(context, provider, project);
                      },
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Open'),
                      onPressed: exists
                          ? () {
                              provider.loadProject(project);
                              Navigator.pop(context);
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, ImageOverlayProvider provider, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteProject(project);
              Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Project deleted')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}