import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/modern_home_page.dart';
import '../../features/scanner/presentation/scanner_page.dart';
import '../../features/pdf_tools/presentation/pdf_tools_page.dart';

/// Application router configuration using GoRouter
class AppRouter {
  AppRouter._();

  // Route paths
  static const String home = '/';
  static const String scanner = '/scanner';
  static const String pdfTools = '/pdf-tools';

  /// Router configuration
  static GoRouter config() {
    return GoRouter(
      initialLocation: home,
      debugLogDiagnostics: true,
      routes: [
        // Home route
        GoRoute(
          path: home,
          name: 'home',
          builder: (context, state) => const ModernHomePage(),
        ),

        // Scanner route
        GoRoute(
          path: scanner,
          name: 'scanner',
          builder: (context, state) => const ScannerPage(),
        ),

        // PDF Tools route
        GoRoute(
          path: pdfTools,
          name: 'pdf-tools',
          builder: (context, state) => const PDFToolsPage(),
        ),
      ],

      // Error page
      errorBuilder:
          (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Page Not Found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The page "${state.uri}" does not exist.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go(home),
                    child: const Text('Go Home'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

/// Extension methods for easier navigation
extension AppRouterExtension on BuildContext {
  /// Navigate to home page
  void goHome() => go(AppRouter.home);

  /// Navigate to scanner page
  void goToScanner() => go(AppRouter.scanner);

  /// Navigate to PDF tools page
  void goToPdfTools() => go(AppRouter.pdfTools);

  /// Push scanner page
  void pushScanner() => push(AppRouter.scanner);

  /// Push PDF tools page
  void pushPdfTools() => push(AppRouter.pdfTools);
}

/// Route information class for type-safe navigation
class AppRoutes {
  AppRoutes._();

  static const RouteInfo home = RouteInfo(
    path: AppRouter.home,
    name: 'home',
    title: 'PDF Scanner Pro',
  );

  static const RouteInfo scanner = RouteInfo(
    path: AppRouter.scanner,
    name: 'scanner',
    title: 'Document Scanner',
  );

  static const RouteInfo pdfTools = RouteInfo(
    path: AppRouter.pdfTools,
    name: 'pdf-tools',
    title: 'PDF Tools',
  );

  static List<RouteInfo> get allRoutes => [home, scanner, pdfTools];
}

/// Route information model
class RouteInfo {
  final String path;
  final String name;
  final String title;

  const RouteInfo({
    required this.path,
    required this.name,
    required this.title,
  });

  @override
  String toString() => 'RouteInfo(path: $path, name: $name, title: $title)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RouteInfo &&
        other.path == path &&
        other.name == name &&
        other.title == title;
  }

  @override
  int get hashCode => path.hashCode ^ name.hashCode ^ title.hashCode;
}
