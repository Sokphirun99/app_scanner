import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Custom icons for the Document Scanner app
/// Provides both SVG asset icons and custom painted icons
class AppIcons {
  AppIcons._();

  // Base path for icon assets
  static const String _iconBasePath = 'assets/icons';

  /// Load an SVG icon from assets
  static Widget svg(
    String iconName, {
    double? size = 24.0,
    Color? color,
    String? semanticLabel,
  }) {
    return SvgPicture.asset(
      '$_iconBasePath/$iconName.svg',
      width: size,
      height: size,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      semanticsLabel: semanticLabel,
    );
  }

  /// Scanner-related icons
  static Widget scanDocument({double? size, Color? color}) =>
      svg('scan_document', size: size, color: color);

  static Widget document({double? size, Color? color}) =>
      svg('document', size: size, color: color);

  static Widget pdfFile({double? size, Color? color}) =>
      svg('pdf_file', size: size, color: color);

  static Widget image({double? size, Color? color}) =>
      svg('image', size: size, color: color);

  /// Action icons
  static Widget checkCircle({double? size, Color? color}) =>
      svg('check_circle', size: size, color: color);

  static Widget view({double? size, Color? color}) =>
      svg('view', size: size, color: color);

  static Widget enhance({double? size, Color? color}) =>
      svg('enhance', size: size, color: color);

  static Widget search({double? size, Color? color}) =>
      svg('search', size: size, color: color);

  /// File operations
  static Widget download({double? size, Color? color}) =>
      svg('download', size: size, color: color);

  static Widget upload({double? size, Color? color}) =>
      svg('upload', size: size, color: color);

  static Widget folder({double? size, Color? color}) =>
      svg('folder', size: size, color: color);

  static Widget layers({double? size, Color? color}) =>
      svg('layers', size: size, color: color);

  /// UI icons
  static Widget star({double? size, Color? color}) =>
      svg('star', size: size, color: color);

  static Widget add({double? size, Color? color}) =>
      svg('add', size: size, color: color);

  /// Custom painted icons (for better performance in some cases)

  /// Camera icon for scanning
  static Widget camera({double size = 24.0, Color? color}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CameraPainter(color: color),
    );
  }

  /// Crop icon for document editing
  static Widget crop({double size = 24.0, Color? color}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CropPainter(color: color),
    );
  }

  /// Rotate icon for document rotation
  static Widget rotate({double size = 24.0, Color? color}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _RotatePainter(color: color),
    );
  }

  /// Filter icon for image filters
  static Widget filter({double size = 24.0, Color? color}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _FilterPainter(color: color),
    );
  }
}

/// Custom painter for camera icon
class _CameraPainter extends CustomPainter {
  final Color? color;

  _CameraPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color ?? Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Camera body
    final cameraRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.1, h * 0.3, w * 0.8, h * 0.6),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(cameraRect, paint);

    // Camera lens
    canvas.drawCircle(Offset(w * 0.5, h * 0.6), w * 0.15, paint);

    // Camera flash
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.65, h * 0.35, w * 0.1, h * 0.1),
        Radius.circular(w * 0.02),
      ),
      paint..style = PaintingStyle.fill,
    );

    // Camera strap
    canvas.drawLine(
      Offset(w * 0.25, h * 0.3),
      Offset(w * 0.25, h * 0.15),
      paint..style = PaintingStyle.stroke,
    );
    canvas.drawLine(
      Offset(w * 0.75, h * 0.3),
      Offset(w * 0.75, h * 0.15),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for crop icon
class _CropPainter extends CustomPainter {
  final Color? color;

  _CropPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color ?? Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;

    final w = size.width;

    // Crop corners
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.2, w * 0.2)
        ..lineTo(w * 0.2, w * 0.35)
        ..moveTo(w * 0.2, w * 0.2)
        ..lineTo(w * 0.35, w * 0.2),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.8, w * 0.2)
        ..lineTo(w * 0.8, w * 0.35)
        ..moveTo(w * 0.8, w * 0.2)
        ..lineTo(w * 0.65, w * 0.2),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.2, w * 0.8)
        ..lineTo(w * 0.2, w * 0.65)
        ..moveTo(w * 0.2, w * 0.8)
        ..lineTo(w * 0.35, w * 0.8),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.8, w * 0.8)
        ..lineTo(w * 0.8, w * 0.65)
        ..moveTo(w * 0.8, w * 0.8)
        ..lineTo(w * 0.65, w * 0.8),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for rotate icon
class _RotatePainter extends CustomPainter {
  final Color? color;

  _RotatePainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color ?? Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w * 0.35;

    // Circular arrow
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.5,
      5.0,
      false,
      paint,
    );

    // Arrow head
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.75, h * 0.35)
        ..lineTo(w * 0.65, h * 0.25)
        ..moveTo(w * 0.75, h * 0.35)
        ..lineTo(w * 0.85, h * 0.25),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for filter icon
class _FilterPainter extends CustomPainter {
  final Color? color;

  _FilterPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color ?? Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Filter funnel
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.15, h * 0.2)
        ..lineTo(w * 0.85, h * 0.2)
        ..lineTo(w * 0.65, h * 0.5)
        ..lineTo(w * 0.65, h * 0.8)
        ..lineTo(w * 0.35, h * 0.8)
        ..lineTo(w * 0.35, h * 0.5)
        ..close(),
      paint,
    );

    // Filter lines
    canvas.drawLine(
      Offset(w * 0.25, h * 0.3),
      Offset(w * 0.75, h * 0.3),
      paint..strokeWidth = 1.0,
    );
    canvas.drawLine(
      Offset(w * 0.35, h * 0.4),
      Offset(w * 0.65, h * 0.4),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
