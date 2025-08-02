# Assets Directory

This directory contains all the assets used in the PDF Scanner app.

## Directory Structure

### `/images/`
- App icons and logos
- Background images
- UI elements

### `/icons/`
- Custom icons for the scanner
- Action icons
- State indicators

### `/illustrations/`
- Empty state illustrations
- Onboarding graphics
- Help/tutorial images

## Usage

To use assets in your Flutter app, reference them like this:

```dart
// For images
Image.asset('assets/images/app_logo.png')

// For icons
Image.asset('assets/icons/scan_icon.png')

// For illustrations
Image.asset('assets/illustrations/empty_state.svg')
```

## Recommended Assets for Scanner App

### Essential Images:
- `app_logo.png` - App logo for splash screen
- `scanner_background.png` - Background for scanner UI
- `pdf_icon.png` - PDF file representation

### Icons:
- `camera_icon.png` - Camera/scan action
- `gallery_icon.png` - Gallery access
- `share_icon.png` - Share functionality
- `delete_icon.png` - Delete action

### Illustrations:
- `empty_state.svg` - When no documents are scanned
- `scanning_progress.svg` - During scanning process
- `success_scan.svg` - Successful scan completion

## Asset Optimization

- Use WebP or PNG for images
- Use SVG for scalable icons when possible
- Provide 2x and 3x variants for better display on different devices
- Keep file sizes optimized for mobile
