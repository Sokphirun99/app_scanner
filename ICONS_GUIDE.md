# App Icons Guide 🎨

This document provides information about the custom icons available in the Document Scanner app.

## 📁 Available Icons

### SVG Icons (Assets)
Located in `assets/icons/` directory:

- `scan_document.svg` - Document scanning icon
- `document.svg` - Generic document icon  
- `pdf_file.svg` - PDF file icon with label
- `image.svg` - Image/photo icon
- `check_circle.svg` - Success/completion icon
- `view.svg` - View/eye icon
- `enhance.svg` - Enhancement/improvement icon
- `search.svg` - Search/magnifying glass icon
- `download.svg` - Download arrow icon
- `upload.svg` - Upload arrow icon
- `folder.svg` - Folder/directory icon
- `layers.svg` - Layers/stacking icon
- `star.svg` - Star/favorite icon
- `add.svg` - Plus/add icon
- `app_icon.svg` - Main app launcher icon

### Custom Painted Icons (Code-based)
Generated programmatically for better performance:

- `camera` - Camera icon for scanning
- `crop` - Crop/resize icon for editing
- `rotate` - Rotation icon for document orientation
- `filter` - Filter icon for image adjustments

## 🚀 Usage Examples

### Basic Usage

```dart
import 'package:app_scanner/core/constants/app_icons.dart';

// SVG icons with default size (24px)
AppIcons.scanDocument()
AppIcons.pdfFile()
AppIcons.enhance()

// Custom size and color
AppIcons.document(size: 32, color: Colors.blue)
AppIcons.checkCircle(size: 40, color: Colors.green)

// Custom painted icons
AppIcons.camera(size: 28, color: Theme.of(context).primaryColor)
AppIcons.crop(size: 24, color: Colors.orange)
```

### In Widgets

```dart
// App Bar
AppBar(
  title: Text('Scanner'),
  actions: [
    IconButton(
      icon: AppIcons.search(),
      onPressed: () => _showSearch(),
    ),
  ],
)

// List Tiles
ListTile(
  leading: AppIcons.pdfFile(color: Colors.red),
  title: Text('Document.pdf'),
  trailing: AppIcons.download(),
)

// Floating Action Button
FloatingActionButton(
  onPressed: _scanDocument,
  child: AppIcons.scanDocument(color: Colors.white),
)

// Buttons
ElevatedButton.icon(
  icon: AppIcons.enhance(),
  label: Text('Enhance'),
  onPressed: _enhanceImage,
)
```

## 🎨 Customization

### Colors
All icons support dynamic coloring:

```dart
// Theme colors
AppIcons.folder(color: Theme.of(context).primaryColor)
AppIcons.star(color: Theme.of(context).colorScheme.secondary)

// Custom colors
AppIcons.pdfFile(color: Colors.red)
AppIcons.enhance(color: Color(0xFF6366F1))
```

### Sizes
Icons can be resized as needed:

```dart
// Small icons (16px)
AppIcons.add(size: 16)

// Medium icons (24px - default)
AppIcons.search()

// Large icons (48px)
AppIcons.scanDocument(size: 48)

// Custom sizes
AppIcons.camera(size: 64)
```

## 📱 Icon Showcase

To see all available icons in action, use the `IconShowcaseWidget`:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => IconShowcaseWidget(),
  ),
);
```

## 🛠️ Adding New Icons

### SVG Icons

1. Create your SVG file in `assets/icons/`
2. Add a getter method to `AppIcons` class:

```dart
static Widget yourIcon({double? size, Color? color}) => 
    svg('your_icon', size: size, color: color);
```

### Custom Painted Icons

1. Create a `CustomPainter` class
2. Add a method to `AppIcons` class:

```dart
static Widget yourCustomIcon({
  double size = 24.0,
  Color? color,
}) {
  return CustomPaint(
    size: Size(size, size),
    painter: YourCustomPainter(color: color),
  );
}
```

## 🎯 Best Practices

1. **Consistency**: Use the same icon family throughout the app
2. **Size**: Stick to standard sizes (16, 24, 32, 48px)
3. **Color**: Use theme colors for consistency
4. **Accessibility**: Always provide semantic labels
5. **Performance**: Use custom painted icons for frequently used icons
6. **Context**: Choose appropriate icons for their context

---

For more information, see the `AppIcons` class documentation in `lib/core/constants/app_icons.dart`.
