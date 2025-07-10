import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static const List<Permission> _requiredPermissions = [
    Permission.camera,
    Permission.storage,
  ];

  /// Request all required permissions for the app
  static Future<Map<Permission, PermissionStatus>> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = {};
    
    for (Permission permission in _requiredPermissions) {
      statuses[permission] = await permission.request();
    }
    
    return statuses;
  }

  /// Check if a specific permission is granted
  static Future<bool> isPermissionGranted(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  /// Check if all required permissions are granted
  static Future<bool> areAllPermissionsGranted() async {
    for (Permission permission in _requiredPermissions) {
      if (!await isPermissionGranted(permission)) {
        return false;
      }
    }
    return true;
  }

  /// Request a specific permission
  static Future<PermissionStatus> requestPermission(Permission permission) async {
    return await permission.request();
  }

  /// Check permission status without requesting
  static Future<PermissionStatus> getPermissionStatus(Permission permission) async {
    return await permission.status;
  }

  /// Open app settings if permissions are denied permanently
  static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Get permission name for display
  static String getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Camera';
      case Permission.storage:
        return 'Storage';
      default:
        return 'Unknown';
    }
  }

  /// Check if permission is permanently denied
  static Future<bool> isPermanentlyDenied(Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }
}
