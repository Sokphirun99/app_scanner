import 'package:flutter/material.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/router/app_router.dart';

/// Example widget showing how to use the new router system
class NavigationExampleWidget extends StatelessWidget {
  const NavigationExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Using extension methods (recommended)
            ElevatedButton(
              onPressed: () => context.goToScanner(),
              child: const Text('Go to Scanner (Extension)'),
            ),

            const SizedBox(height: 12),

            // Using navigation service
            ElevatedButton(
              onPressed: () => NavigationService.goToPdfTools(context),
              child: const Text('Go to PDF Tools (Service)'),
            ),

            const SizedBox(height: 12),

            // Push instead of replace (keeps current page in stack)
            ElevatedButton(
              onPressed: () => context.pushScanner(),
              child: const Text('Push Scanner (Keep Stack)'),
            ),

            const SizedBox(height: 12),

            // Go back
            ElevatedButton(
              onPressed: () => context.navigateBack(),
              child: const Text('Go Back'),
            ),

            const SizedBox(height: 24),

            // Current route information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Route Info:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('Is Home: ${context.isHome}'),
                  Text('Is Scanner: ${context.isScanner}'),
                  Text('Is PDF Tools: ${context.isPdfTools}'),
                  Text('Can Go Back: ${NavigationService.canGoBack(context)}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example of how to replace existing navigation in your buttons
class ScannerButtonWithRouter extends StatelessWidget {
  const ScannerButtonWithRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      // OLD WAY:
      // onPressed: () => Navigator.of(context).push(
      //   MaterialPageRoute(builder: (context) => const ScannerPage()),
      // ),

      // NEW WAY (choose one):
      onPressed: () => context.goToScanner(), // Extension method

      // OR: onPressed: () => NavigationService.goToScanner(context), // Service method
      icon: const Icon(Icons.document_scanner),
      label: const Text('Open Scanner'),
    );
  }
}

/// Example of how to update your existing buttons
class UpdatedToolButtons extends StatelessWidget {
  const UpdatedToolButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Scanner button
        _buildToolButton(
          context,
          icon: Icons.document_scanner,
          label: 'Scanner',
          onPressed: () => context.goToScanner(),
        ),

        // PDF Tools button
        _buildToolButton(
          context,
          icon: Icons.picture_as_pdf,
          label: 'PDF Tools',
          onPressed: () => context.goToPdfTools(),
        ),

        // Home button
        _buildToolButton(
          context,
          icon: Icons.home,
          label: 'Home',
          onPressed: () => context.goHome(),
        ),
      ],
    );
  }

  Widget _buildToolButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(onPressed: onPressed, icon: Icon(icon), iconSize: 32),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
