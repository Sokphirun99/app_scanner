import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

/// Navigation service for the PDF Scanner app
/// Provides convenient methods for navigation throughout the app
class NavigationService {
  NavigationService._();

  /// Navigate to home page
  static void goToHome(BuildContext context) {
    context.goHome();
  }

  /// Navigate to scanner page
  static void goToScanner(BuildContext context) {
    context.goToScanner();
  }

  /// Navigate to PDF tools page
  static void goToPdfTools(BuildContext context) {
    context.goToPdfTools();
  }

  /// Push scanner page (keeps current page in stack)
  static void pushScanner(BuildContext context) {
    context.pushScanner();
  }

  /// Push PDF tools page (keeps current page in stack)
  static void pushPdfTools(BuildContext context) {
    context.pushPdfTools();
  }

  /// Go back to previous page
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goHome();
    }
  }

  /// Replace current page with new route
  static void goAndReplace(BuildContext context, String route) {
    context.pushReplacement(route);
  }

  /// Clear navigation stack and go to specific route
  static void goAndClearStack(BuildContext context, String route) {
    context.go(route);
  }

  /// Show a modal bottom sheet with custom content
  static Future<T?> showModalBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      builder: builder,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
    );
  }

  /// Show a dialog with custom content
  static Future<T?> showDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
  }) {
    return showDialog<T>(
      context: context,
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
    );
  }

  /// Get current route information
  static RouteInfo? getCurrentRoute(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    return AppRoutes.allRoutes
        .where((route) => route.path == location)
        .firstOrNull;
  }

  /// Check if we can navigate back
  static bool canGoBack(BuildContext context) {
    return context.canPop();
  }

  /// Navigate with custom transition
  static void navigateWithTransition(
    BuildContext context,
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: duration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: curve)),
            ),
            child: child,
          );
        },
      ),
    );
  }
}

/// Extension for additional navigation convenience methods
extension NavigationExtension on BuildContext {
  /// Quick access to navigation service methods
  void navigateToHome() => NavigationService.goToHome(this);
  void navigateToScanner() => NavigationService.goToScanner(this);
  void navigateToPdfTools() => NavigationService.goToPdfTools(this);
  void navigateBack() => NavigationService.goBack(this);

  /// Check current route
  bool get isHome => GoRouterState.of(this).uri.toString() == AppRouter.home;
  bool get isScanner =>
      GoRouterState.of(this).uri.toString() == AppRouter.scanner;
  bool get isPdfTools =>
      GoRouterState.of(this).uri.toString() == AppRouter.pdfTools;
}
