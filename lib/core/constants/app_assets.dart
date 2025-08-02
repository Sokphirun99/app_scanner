import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Asset paths for the PDF Scanner app
/// This class provides centralized access to all app assets
class AppAssets {
  AppAssets._(); // Private constructor to prevent instantiation

  // Base paths
  static const String _imagesPath = 'assets/images';
  static const String _iconsPath = 'assets/icons';
  static const String _illustrationsPath = 'assets/illustrations';

  // Images
  static const String appLogo = '$_imagesPath/app_logo.png';
  static const String appIcon = '$_imagesPath/app_icon.png';
  static const String splashBackground = '$_imagesPath/splash_background.png';
  static const String scannerOverlay = '$_imagesPath/scanner_overlay.png';
  static const String pdfPreview = '$_imagesPath/pdf_preview.png';

  // Icons
  static const String scanIcon = '$_iconsPath/scan.png';
  static const String galleryIcon = '$_iconsPath/gallery.png';
  static const String cameraIcon = '$_iconsPath/camera.png';
  static const String pdfIcon = '$_iconsPath/pdf.png';
  static const String shareIcon = '$_iconsPath/share.png';
  static const String deleteIcon = '$_iconsPath/delete.png';
  static const String editIcon = '$_iconsPath/edit.png';
  static const String previewIcon = '$_iconsPath/preview.png';

  // Illustrations
  static const String emptyState = '$_illustrationsPath/empty_state.svg';
  static const String scanningAnimation =
      '$_illustrationsPath/scanning_animation.svg';
  static const String successIllustration =
      '$_illustrationsPath/success_illustration.svg';
  static const String errorIllustration =
      '$_illustrationsPath/error_illustration.svg';
  static const String onboarding1 = '$_illustrationsPath/onboarding_1.svg';
  static const String onboarding2 = '$_illustrationsPath/onboarding_2.svg';
  static const String tutorialScan = '$_illustrationsPath/tutorial_scan.svg';

  // Helper methods for loading assets

  /// Returns an Image widget for the given asset path
  static Widget image(
    String assetPath, {
    double? width,
    double? height,
    BoxFit? fit,
    String? semanticLabel,
  }) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: semanticLabel,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );
  }

  /// Returns an Image widget for icons with default sizing
  static Widget icon(
    String assetPath, {
    double size = 24.0,
    Color? color,
    String? semanticLabel,
  }) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      color: color,
      semanticLabel: semanticLabel,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.broken_image,
          size: size,
          color: color ?? Colors.grey,
        );
      },
    );
  }

  /// Check if asset exists (for development/debugging)
  static Future<bool> assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// List all available assets (for debugging)
  static List<String> getAllAssets() {
    return [
      // Images
      appLogo,
      appIcon,
      splashBackground,
      scannerOverlay,
      pdfPreview,

      // Icons
      scanIcon,
      galleryIcon,
      cameraIcon,
      pdfIcon,
      shareIcon,
      deleteIcon,
      editIcon,
      previewIcon,

      // Illustrations
      emptyState,
      scanningAnimation,
      successIllustration,
      errorIllustration,
      onboarding1,
      onboarding2,
      tutorialScan,
    ];
  }
}

// Extension methods for easier asset usage
extension AssetWidgets on AppAssets {
  // Quick access methods for common assets
  static Widget get logo => AppAssets.image(AppAssets.appLogo);
  static Widget get scanButton => AppAssets.icon(AppAssets.scanIcon);
  static Widget get pdfButton => AppAssets.icon(AppAssets.pdfIcon);
}
