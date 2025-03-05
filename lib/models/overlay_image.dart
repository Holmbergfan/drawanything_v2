import 'dart:io';
import 'package:flutter/material.dart';

class OverlayImage {
  final String path;
  final File imageFile;
  final Offset position;
  final double scale;
  final double rotation;
  final double opacity;
  final bool isFlippedHorizontally;
  final bool isFlippedVertically;
  final String? filter;

  const OverlayImage({
    required this.path,
    required this.imageFile,
    this.position = Offset.zero,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.opacity = 1.0,
    this.isFlippedHorizontally = false,
    this.isFlippedVertically = false,
    this.filter,
  });

  OverlayImage copyWith({
    String? path,
    File? imageFile,
    Offset? position,
    double? scale,
    double? rotation,
    double? opacity,
    bool? isFlippedHorizontally,
    bool? isFlippedVertically,
    String? filter,
  }) {
    return OverlayImage(
      path: path ?? this.path,
      imageFile: imageFile ?? this.imageFile,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
      isFlippedHorizontally: isFlippedHorizontally ?? this.isFlippedHorizontally,
      isFlippedVertically: isFlippedVertically ?? this.isFlippedVertically,
      filter: filter,  // Allow null to clear filter
    );
  }

  OverlayImage reset() {
    return OverlayImage(
      path: path,
      imageFile: imageFile,
      position: Offset.zero,
      scale: 1.0,
      rotation: 0.0,
      opacity: 1.0,
      isFlippedHorizontally: false,
      isFlippedVertically: false,
      filter: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'position': {'dx': position.dx, 'dy': position.dy},
      'scale': scale,
      'rotation': rotation,
      'opacity': opacity,
      'isFlippedHorizontally': isFlippedHorizontally,
      'isFlippedVertically': isFlippedVertically,
      'filter': filter,
    };
  }

  factory OverlayImage.fromJson(Map<String, dynamic> json) {
    return OverlayImage(
      path: json['path'],
      imageFile: File(json['path']),
      position: Offset(json['position']['dx'], json['position']['dy']),
      scale: json['scale'],
      rotation: json['rotation'],
      opacity: json['opacity'],
      isFlippedHorizontally: json['isFlippedHorizontally'],
      isFlippedVertically: json['isFlippedVertically'],
      filter: json['filter'],
    );
  }
}
