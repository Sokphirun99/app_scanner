import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Fallback scanner service using image picker
/// Used when the main document scanner fails
class FallbackScannerService {
  final ImagePicker _picker = ImagePicker();
  final _uuid = const Uuid();

  /// Scan documents using the camera (fallback method)
  Future<List<String>> scanDocumentsWithCamera({int maxImages = 5}) async {
    try {
      final List<String> savedImagePaths = [];
      final scanDir = await _ensureScanDirectory();

      // Take photos one by one (since image_picker doesn't support multiple at once)
      for (int i = 0; i < maxImages; i++) {
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
          preferredCameraDevice: CameraDevice.rear,
        );

        if (photo != null) {
          final savedPath = await _saveScannedImage(photo.path, scanDir);
          if (savedPath != null) {
            savedImagePaths.add(savedPath);
          }

          // Ask user if they want to scan more
          if (i < maxImages - 1) {
            // In a real implementation, you'd show a dialog here
            // For now, we'll just take one photo
            break;
          }
        } else {
          // User cancelled or no photo taken
          break;
        }
      }

      return savedImagePaths;
    } catch (e) {
      debugPrint('Fallback scanner error: $e');
      return [];
    }
  }

  /// Import images from gallery
  Future<List<String>> importFromGallery({int maxImages = 5}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
        limit: maxImages,
      );

      if (images.isEmpty) {
        return [];
      }

      final List<String> savedImagePaths = [];
      final scanDir = await _ensureScanDirectory();

      for (final image in images) {
        final savedPath = await _saveScannedImage(image.path, scanDir);
        if (savedPath != null) {
          savedImagePaths.add(savedPath);
        }
      }

      return savedImagePaths;
    } catch (e) {
      debugPrint('Gallery import error: $e');
      return [];
    }
  }

  /// Create the directory for storing scanned documents
  Future<Directory> _ensureScanDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final scanDir = Directory(path.join(tempDir.path, 'scanned_docs'));

    if (!await scanDir.exists()) {
      await scanDir.create(recursive: true);
    }

    return scanDir;
  }

  /// Save a scanned image to the app directory with a unique filename
  Future<String?> _saveScannedImage(String imagePath, Directory scanDir) async {
    try {
      // Generate a unique filename
      final uuid = _uuid.v4();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newFilename = 'scan_${timestamp}_$uuid.jpg';
      final savedPath = path.join(scanDir.path, newFilename);

      // Copy the file to our app's directory
      final file = File(imagePath);
      if (await file.exists()) {
        await file.copy(savedPath);
        return savedPath;
      }
    } catch (e) {
      debugPrint('Error saving scanned image: $e');
    }
    return null;
  }
}
