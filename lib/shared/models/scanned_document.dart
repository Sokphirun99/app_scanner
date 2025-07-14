import 'dart:io';

class ScannedDocument {
  final String id;
  final String imagePath;
  final DateTime createdAt;
  final String? title;
  final bool isPdf;

  ScannedDocument({
    required this.id,
    required this.imagePath,
    required this.createdAt,
    this.title,
    this.isPdf = false,
  });

  ScannedDocument copyWith({
    String? id,
    String? imagePath,
    DateTime? createdAt,
    String? title,
    bool? isPdf,
  }) {
    return ScannedDocument(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      isPdf: isPdf ?? this.isPdf,
    );
  }

  File get imageFile => File(imagePath);

  bool get exists => imageFile.existsSync();

  String get fileName => imagePath.split('/').last;
  
  /// Get detailed file information for debugging
  Map<String, dynamic> get fileInfo {
    final file = imageFile;
    try {
      return {
        'path': imagePath,
        'exists': file.existsSync(),
        'size': file.existsSync() ? file.lengthSync() : 0,
        'extension': fileName.split('.').last.toLowerCase(),
        'lastModified': file.existsSync() ? file.lastModifiedSync().toIso8601String() : null,
        'isReadable': file.existsSync() && file.statSync().mode & 0x100 != 0,
      };
    } catch (e) {
      return {
        'path': imagePath,
        'exists': false,
        'error': e.toString(),
      };
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScannedDocument &&
        other.id == id &&
        other.imagePath == imagePath &&
        other.createdAt == createdAt &&
        other.title == title &&
        other.isPdf == isPdf;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        imagePath.hashCode ^
        createdAt.hashCode ^
        title.hashCode ^
        isPdf.hashCode;
  }

  @override
  String toString() {
    return 'ScannedDocument(id: $id, imagePath: $imagePath, createdAt: $createdAt, title: $title, isPdf: $isPdf)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'title': title,
      'isPdf': isPdf,
    };
  }

  factory ScannedDocument.fromJson(Map<String, dynamic> json) {
    return ScannedDocument(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      title: json['title'] as String?,
      isPdf: json['isPdf'] as bool? ?? false,
    );
  }
}
