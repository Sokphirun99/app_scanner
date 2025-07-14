import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ImagePreviewPage extends StatefulWidget {
  final String imagePath;
  final int imageIndex;
  final int totalImages;
  final Function(String)? onImageDeleted;

  const ImagePreviewPage({
    super.key,
    required this.imagePath,
    required this.imageIndex,
    required this.totalImages,
    this.onImageDeleted,
  });

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  bool _imageExists = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkImageExists();
  }

  Future<void> _checkImageExists() async {
    try {
      final file = File(widget.imagePath);
      final exists = await file.exists();
      setState(() {
        _imageExists = exists;
        _isLoading = false;
        if (!exists) {
          _errorMessage = 'Image file not found at: ${widget.imagePath}';
        }
      });
    } catch (e) {
      setState(() {
        _imageExists = false;
        _isLoading = false;
        _errorMessage = 'Error checking image: $e';
      });
    }
  }

  Future<void> _confirmDeleteImage(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Image'),
            content: const Text(
              'Are you sure you want to delete this image? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      await _deleteImage(context);
    }
  }

  Future<void> _deleteImage(BuildContext context) async {
    try {
      final file = File(widget.imagePath);
      if (file.existsSync()) {
        await file.delete();
        widget.onImageDeleted?.call(widget.imagePath);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image file not found'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareImage(BuildContext context) async {
    try {
      final file = File(widget.imagePath);
      if (file.existsSync()) {
        await Share.shareXFiles([
          XFile(widget.imagePath),
        ], text: 'Scanned document image');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image file not found'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveImageCopy(BuildContext context) async {
    try {
      final file = File(widget.imagePath);
      if (!file.existsSync()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Original image file not found'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final originalFileName = widget.imagePath.split('/').last;
      final extension = originalFileName.split('.').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newFileName = 'copy_$timestamp.$extension';
      final newPath = widget.imagePath.replaceFirst(
        RegExp(r'[^/]+$'),
        newFileName,
      );

      await file.copy(newPath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image saved as: $newFileName'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Share Copy',
              onPressed: () async {
                await Share.shareXFiles([XFile(newPath)]);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save image copy: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageInfo(BuildContext context) {
    final file = File(widget.imagePath);
    final fileExists = file.existsSync();
    
    // Collect detailed file information
    final info = <String, dynamic>{
      'path': widget.imagePath,
      'exists': fileExists,
    };
    
    if (fileExists) {
      try {
        final stat = file.statSync();
        info.addAll({
          'size': file.lengthSync(),
          'sizeKB': (file.lengthSync() / 1024).toStringAsFixed(2),
          'lastModified': file.lastModifiedSync().toString().split('.').first,
          'permissions': stat.mode.toRadixString(8),
          'type': stat.type.toString(),
        });
      } catch (e) {
        info['statError'] = e.toString();
      }
    }
    
    final fileName = widget.imagePath.split('/').last;
    final fileExtension = fileName.split('.').last.toUpperCase();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Image Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('File: $fileName'),
              const SizedBox(height: 8),
              Text('Format: $fileExtension'),
              const SizedBox(height: 8),
              Text('Size: ${info['sizeKB'] ?? 'Unknown'} KB'),
              const SizedBox(height: 8),
              Text('Modified: ${info['lastModified'] ?? 'Unknown'}'),
              const SizedBox(height: 8),
              Text('Permissions: ${info['permissions'] ?? 'Unknown'}'),
              const SizedBox(height: 8),
              Text('Exists: ${info['exists'] ? 'Yes' : 'No'}'),
              const SizedBox(height: 8),
              Text('Loading State: ${_isLoading ? 'Loading' : 'Complete'}'),
              const SizedBox(height: 8),
              Text('Image Valid: ${_imageExists ? 'Yes' : 'No'}'),
              const SizedBox(height: 12),
              const Text('Full Path:', style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(
                widget.imagePath,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                const Text('Error:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              if (info['statError'] != null) ...[
                const SizedBox(height: 12),
                const Text('File System Error:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                Text(
                  info['statError'].toString(),
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image ${widget.imageIndex} of ${widget.totalImages}'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showImageInfo(context),
            tooltip: 'Image Info',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareImage(context),
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: () => _saveImageCopy(context),
            tooltip: 'Save Copy',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDeleteImage(context),
            tooltip: 'Delete',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close',
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _imageExists
              ? Stack(
                children: [
                  Center(
                    child: InteractiveViewer(
                      maxScale: 5.0,
                      minScale: 0.5,
                      child: Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Failed to load image: $error');
                          debugPrint('Stack trace: $stackTrace');
                          debugPrint('Image path: ${widget.imagePath}');
                          debugPrint(
                            'File exists: ${File(widget.imagePath).existsSync()}',
                          );
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 100,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Failed to load image. Please check the file path or permissions.',
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton(
                          heroTag: 'info',
                          onPressed: () => _showImageInfo(context),
                          backgroundColor: Colors.blue,
                          child: const Icon(Icons.info_outline),
                        ),
                        const SizedBox(height: 12),
                        FloatingActionButton(
                          heroTag: 'share',
                          onPressed: () => _shareImage(context),
                          backgroundColor: Colors.green,
                          child: const Icon(Icons.share),
                        ),
                        const SizedBox(height: 12),
                        FloatingActionButton(
                          heroTag: 'save',
                          onPressed: () => _saveImageCopy(context),
                          backgroundColor: Colors.orange,
                          child: const Icon(Icons.save_alt),
                        ),
                        const SizedBox(height: 12),
                        FloatingActionButton(
                          heroTag: 'delete',
                          onPressed: () => _confirmDeleteImage(context),
                          backgroundColor: Colors.red,
                          child: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                ],
              )
              : Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 100,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage ?? 'An unknown error occurred',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
