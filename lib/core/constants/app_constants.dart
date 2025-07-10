class AppConstants {
  // App Information
  static const String appName = 'PDF Scanner';
  static const String appVersion = '1.0.0';

  // Strings
  static const String scanDocument = 'Scan Document';
  static const String generatePDF = 'Generate PDF';
  static const String clearAll = 'Clear All';
  static const String share = 'Share';
  static const String preview = 'Preview';
  static const String delete = 'Delete';
  static const String processing = 'Processing...';
  static const String noDocumentsScanned = 'No documents scanned yet';
  static const String tapCameraToStart = 'Tap the camera button to start scanning';
  
  // Error Messages
  static const String errorScanningDocument = 'Error scanning document';
  static const String errorGeneratingPDF = 'Error generating PDF';
  static const String errorSharingPDF = 'Error sharing PDF';
  static const String noScannedImages = 'No scanned images to generate PDF';
  
  // Success Messages
  static const String scanSuccessful = 'Successfully scanned';
  static const String documentsText = 'document(s)';
  static const String pdfSavedTo = 'PDF saved to';
  static const String clearedAllImages = 'Cleared all scanned images';
  
  // File Names
  static const String pdfFilePrefix = 'scanned_document_';
  static const String pdfExtension = '.pdf';
  
  // Dimensions
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double iconSize = 64.0;
  static const double cardElevation = 4.0;
  static const double gridAspectRatio = 0.7;
  static const int gridCrossAxisCount = 2;
  
  // Durations
  static const Duration eglCleanupDelay = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
}
