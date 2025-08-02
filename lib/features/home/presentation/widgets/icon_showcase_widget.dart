import 'package:flutter/material.dart';
import '../../../../core/constants/app_icons.dart';

/// Demo widget showing all available custom icons
class IconShowcaseWidget extends StatelessWidget {
  const IconShowcaseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Icons Showcase'),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: _iconItems.length,
          itemBuilder: (context, index) {
            final item = _iconItems[index];
            return _IconCard(
              icon: item.icon,
              name: item.name,
              onTap: () => _showIconDetails(context, item),
            );
          },
        ),
      ),
    );
  }

  void _showIconDetails(BuildContext context, _IconItem item) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(item.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                item.icon,
                const SizedBox(height: 16),
                Text(
                  'Usage: AppIcons.${item.name.toLowerCase().replaceAll(' ', '')}()',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  static final List<_IconItem> _iconItems = [
    // SVG Icons
    _IconItem(
      'Scan Document',
      AppIcons.scanDocument(size: 32, color: Colors.blue),
    ),
    _IconItem('Document', AppIcons.document(size: 32, color: Colors.green)),
    _IconItem('PDF File', AppIcons.pdfFile(size: 32, color: Colors.red)),
    _IconItem('Image', AppIcons.image(size: 32, color: Colors.purple)),
    _IconItem(
      'Check Circle',
      AppIcons.checkCircle(size: 32, color: Colors.green),
    ),
    _IconItem('View', AppIcons.view(size: 32, color: Colors.orange)),
    _IconItem('Enhance', AppIcons.enhance(size: 32, color: Colors.cyan)),
    _IconItem('Search', AppIcons.search(size: 32, color: Colors.indigo)),
    _IconItem('Download', AppIcons.download(size: 32, color: Colors.teal)),
    _IconItem('Upload', AppIcons.upload(size: 32, color: Colors.amber)),
    _IconItem('Folder', AppIcons.folder(size: 32, color: Colors.brown)),
    _IconItem('Layers', AppIcons.layers(size: 32, color: Colors.deepPurple)),
    _IconItem('Star', AppIcons.star(size: 32, color: Colors.yellow)),
    _IconItem('Add', AppIcons.add(size: 32, color: Colors.pink)),

    // Custom Painted Icons
    _IconItem('Camera', AppIcons.camera(size: 32, color: Colors.blue)),
    _IconItem('Crop', AppIcons.crop(size: 32, color: Colors.green)),
    _IconItem('Rotate', AppIcons.rotate(size: 32, color: Colors.orange)),
    _IconItem('Filter', AppIcons.filter(size: 32, color: Colors.purple)),
  ];
}

class _IconCard extends StatelessWidget {
  final Widget icon;
  final String name;
  final VoidCallback onTap;

  const _IconCard({
    required this.icon,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(height: 8),
              Text(
                name,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconItem {
  final String name;
  final Widget icon;

  _IconItem(this.name, this.icon);
}

/// Widget demonstrating icon usage in real scenarios
class IconUsageExamplesWidget extends StatelessWidget {
  const IconUsageExamplesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Icon Usage Examples'),
        actions: [
          IconButton(icon: AppIcons.search(), onPressed: () {}),
          IconButton(icon: AppIcons.folder(), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Scanner Action Card
          Card(
            child: ListTile(
              leading: AppIcons.scanDocument(
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Scan Document'),
              subtitle: const Text('Capture a new document'),
              trailing: AppIcons.camera(size: 24),
              onTap: () {},
            ),
          ),

          const SizedBox(height: 16),

          // Document Grid Example
          const Text(
            'Document Grid',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            children: [
              _DocumentCard(
                icon: AppIcons.pdfFile(size: 48, color: Colors.red),
                title: 'Invoice.pdf',
                subtitle: '2.4 MB',
              ),
              _DocumentCard(
                icon: AppIcons.image(size: 48, color: Colors.blue),
                title: 'Receipt.jpg',
                subtitle: '1.2 MB',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons
          const Text(
            'Action Buttons',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionChip(icon: AppIcons.enhance(), label: 'Enhance'),
              _ActionChip(icon: AppIcons.crop(), label: 'Crop'),
              _ActionChip(icon: AppIcons.rotate(), label: 'Rotate'),
              _ActionChip(icon: AppIcons.filter(), label: 'Filter'),
              _ActionChip(icon: AppIcons.download(), label: 'Download'),
              _ActionChip(icon: AppIcons.upload(), label: 'Upload'),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: AppIcons.add(),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;

  const _DocumentCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final Widget icon;
  final String label;

  const _ActionChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ActionChip(avatar: icon, label: Text(label), onPressed: () {});
  }
}
