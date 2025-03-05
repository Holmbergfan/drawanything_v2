// lib/utils/file_utils.dart
import 'dart:io';

class FileUtils {
  static Future<bool> fileExists(String path) async {
    final file = File(path);
    return await file.exists();
  }
  
  // Add other file-related utilities as needed
}