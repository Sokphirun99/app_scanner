import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';

/// Example widget showing how to use the assets system
/// This can be used as a reference for implementing custom graphics
class AssetsExampleWidget extends StatelessWidget {
  const AssetsExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assets Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Using Images
            _buildSection('Images', [
              _buildAssetExample(
                'App Logo',
                AppAssets.image(AppAssets.appLogo, width: 100, height: 100),
              ),
              _buildAssetExample(
                'Splash Background',
                AppAssets.image(
                  AppAssets.splashBackground,
                  width: 200,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ]),

            const SizedBox(height: 24),

            // Section: Using Icons
            _buildSection('Icons', [
              _buildAssetExample(
                'Scan Icon',
                AppAssets.icon(AppAssets.scanIcon, size: 32),
              ),
              _buildAssetExample(
                'PDF Icon',
                AppAssets.icon(AppAssets.pdfIcon, size: 32, color: Colors.red),
              ),
              _buildAssetExample(
                'Share Icon',
                AppAssets.icon(
                  AppAssets.shareIcon,
                  size: 32,
                  color: Colors.blue,
                ),
              ),
            ]),

            const SizedBox(height: 24),

            // Section: Quick Access Methods
            _buildSection('Quick Access', [
              _buildAssetExample('Logo (Quick)', AssetWidgets.logo),
              _buildAssetExample(
                'Scan Button (Quick)',
                AssetWidgets.scanButton,
              ),
              _buildAssetExample('PDF Button (Quick)', AssetWidgets.pdfButton),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> examples) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 16, runSpacing: 16, children: examples),
      ],
    );
  }

  Widget _buildAssetExample(String label, Widget assetWidget) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          assetWidget,
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Example of how to integrate assets into your existing scanner UI
class ScannerButtonWithAssets extends StatelessWidget {
  final VoidCallback onPressed;

  const ScannerButtonWithAssets({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: AppAssets.icon(AppAssets.scanIcon, size: 24, color: Colors.white),
      label: const Text('Scan Document'),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }
}

/// Example of using assets in empty state
class EmptyStateWithAssets extends StatelessWidget {
  final VoidCallback onScanPressed;

  const EmptyStateWithAssets({super.key, required this.onScanPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Use illustration asset when available
          AppAssets.image(AppAssets.emptyState, width: 200, height: 200),
          const SizedBox(height: 24),
          Text(
            'No Documents Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            'Start scanning documents to build your digital library',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onScanPressed,
            icon: AppAssets.icon(AppAssets.scanIcon, size: 20),
            label: const Text('Start Scanning'),
          ),
        ],
      ),
    );
  }
}
