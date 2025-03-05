import 'overlay_image.dart';

class Project {
  final String name;
  final DateTime date;
  final OverlayImage overlayImage;

  Project({
    required this.name,
    required this.date,
    required this.overlayImage,
  });

  // Constructor for loading from saved data
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      overlayImage: OverlayImage.fromJson(json['overlayImage'] as Map<String, dynamic>),
    );
  }

  // Convert to JSON for saving
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'overlayImage': overlayImage.toJson(),
    };
  }
}