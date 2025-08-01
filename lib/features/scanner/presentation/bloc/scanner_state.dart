import 'package:equatable/equatable.dart';
import '../../../../shared/models/scanned_document.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object> get props => [];
}

// Mixin to provide documents to states
mixin DocumentsMixin {
  List<ScannedDocument> get documents;
}

class ScannerInitial extends ScannerState with DocumentsMixin {
  @override
  final List<ScannedDocument> documents;

  const ScannerInitial([this.documents = const []]);

  @override
  List<Object> get props => [documents];
}

class ScannerLoading extends ScannerState with DocumentsMixin {
  @override
  final List<ScannedDocument> documents;

  const ScannerLoading([this.documents = const []]);

  @override
  List<Object> get props => [documents];
}

class ScannerLoaded extends ScannerState with DocumentsMixin {
  @override
  final List<ScannedDocument> documents;

  const ScannerLoaded(this.documents);

  @override
  List<Object> get props => [documents];
}

class ScannerError extends ScannerState with DocumentsMixin {
  final String message;
  @override
  final List<ScannedDocument> documents;

  const ScannerError(this.message, [this.documents = const []]);

  @override
  List<Object> get props => [message, documents];
}

class ScannerSuccess extends ScannerState with DocumentsMixin {
  final String message;
  @override
  final List<ScannedDocument> documents;

  const ScannerSuccess(this.message, this.documents);

  @override
  List<Object> get props => [message, documents];
}

class ScannerCancelled extends ScannerState with DocumentsMixin {
  @override
  final List<ScannedDocument> documents;

  const ScannerCancelled(this.documents);

  @override
  List<Object> get props => [documents];
}

class PdfGenerated extends ScannerState with DocumentsMixin {
  final String pdfPath;
  @override
  final List<ScannedDocument> documents;

  const PdfGenerated(this.pdfPath, this.documents);

  @override
  List<Object> get props => [pdfPath, documents];
}
