import 'package:equatable/equatable.dart';
import '../../../../shared/models/scanned_document.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object> get props => [];
}

class ScannerInitial extends ScannerState {
  final List<ScannedDocument> documents;

  const ScannerInitial([this.documents = const []]);

  @override
  List<Object> get props => [documents];
}

class ScannerLoading extends ScannerState {
  final List<ScannedDocument> documents;

  const ScannerLoading([this.documents = const []]);

  @override
  List<Object> get props => [documents];
}

class ScannerLoaded extends ScannerState {
  final List<ScannedDocument> documents;

  const ScannerLoaded(this.documents);

  @override
  List<Object> get props => [documents];
}

class ScannerError extends ScannerState {
  final String message;
  final List<ScannedDocument> documents;

  const ScannerError(this.message, [this.documents = const []]);

  @override
  List<Object> get props => [message, documents];
}

class ScannerSuccess extends ScannerState {
  final String message;
  final List<ScannedDocument> documents;

  const ScannerSuccess(this.message, this.documents);

  @override
  List<Object> get props => [message, documents];
}

class ScannerCancelled extends ScannerState {
  final List<ScannedDocument> documents;

  const ScannerCancelled(this.documents);

  @override
  List<Object> get props => [documents];
}

class PdfGenerated extends ScannerState {
  final String pdfPath;
  final List<ScannedDocument> documents;

  const PdfGenerated(this.pdfPath, this.documents);

  @override
  List<Object> get props => [pdfPath, documents];
}
