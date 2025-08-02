import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../shared/models/scanned_document.dart';

class ModernDocumentCard extends StatelessWidget {
  final ScannedDocument document;
  final VoidCallback onPreview;
  final VoidCallback onDelete;
  final VoidCallback? onShare;
  final VoidCallback? onEdit;

  const ModernDocumentCard({
    super.key,
    required this.document,
    required this.onPreview,
    required this.onDelete,
    this.onShare,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onPreview,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Document Preview - Optimized
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                  child: Container(
                    color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
                    child: _buildDocumentPreview(context),
                  ),
                ),
              ),
              
              // Document Info
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title and type
                      Row(
                        children: [
                          Icon(
                            document.isPdf ? Icons.picture_as_pdf : Icons.image,
                            size: 16.sp,
                            color: theme.colorScheme.primary,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              _getDocumentTitle(),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 4.h),
                      
                      // Actions row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDate(document.createdAt),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          
                          // Action buttons
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: onPreview,
                                child: Icon(
                                  Icons.visibility_outlined,
                                  size: 18.sp,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              
                              if (onShare != null) ...[
                                SizedBox(width: 8.w),
                                GestureDetector(
                                  onTap: onShare!,
                                  child: Icon(
                                    Icons.share_outlined,
                                    size: 18.sp,
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ],
                              
                              SizedBox(width: 8.w),
                              GestureDetector(
                                onTap: onDelete,
                                child: Icon(
                                  Icons.delete_outline,
                                  size: 18.sp,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentPreview(BuildContext context) {
    if (document.isPdf) {
      return _buildPdfPreview(context);
    } else {
      return _buildImagePreview(context);
    }
  }

  Widget _buildPdfPreview(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf,
            size: 48.sp,
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: 8.h),
          Text(
            'PDF Document',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    final theme = Theme.of(context);
    final imageFile = File(document.imagePath);
    
    return imageFile.existsSync()
        ? Image.file(
            imageFile,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            // Performance optimization: cache images
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: child,
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorPreview(context);
            },
          )
        : _buildErrorPreview(context);
  }

  Widget _buildErrorPreview(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 32.sp,
            color: theme.colorScheme.error,
          ),
          SizedBox(height: 8.h),
          Text(
            'Image not found',
            style: TextStyle(
              fontSize: 10.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _getDocumentTitle() {
    final fileName = document.imagePath.split('/').last;
    if (fileName.length > 15) {
      return '${fileName.substring(0, 12)}...';
    }
    return fileName;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Performance-optimized empty state widget
class ModernEmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const ModernEmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64.sp,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            
            SizedBox(height: 24.h),
            
            Text(
              title,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 12.h),
            
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16.sp,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (actionText != null && onAction != null) ...[
              SizedBox(height: 32.h),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(Icons.add, size: 20.sp),
                label: Text(
                  actionText!,
                  style: TextStyle(fontSize: 16.sp),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
