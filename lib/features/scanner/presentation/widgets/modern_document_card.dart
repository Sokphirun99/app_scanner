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
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16.r),
                          ),
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        ),
                        child: _buildDocumentPreview(context, theme),
                      ),
                    ),
                    
                    // Document Info
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(16.r),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // File name
                            Text(
                              _getDisplayName(),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            
                            // File info
                            Row(
                              children: [
                                Icon(
                                  widget.document.isPdf ? Icons.picture_as_pdf : Icons.image,
                                  size: 14.sp,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    _getFileInfo(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            
                            const Spacer(),
                            
                            // Action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildIconButton(
                                  context,
                                  icon: Icons.visibility_outlined,
                                  onPressed: widget.onPreview,
                                  tooltip: 'Preview',
                                  color: theme.colorScheme.primary,
                                ),
                                if (widget.onShare != null)
                                  _buildIconButton(
                                    context,
                                    icon: Icons.share_outlined,
                                    onPressed: widget.onShare!,
                                    tooltip: 'Share',
                                    color: theme.colorScheme.secondary,
                                  ),
                                if (widget.onEdit != null)
                                  _buildIconButton(
                                    context,
                                    icon: Icons.edit_outlined,
                                    onPressed: widget.onEdit!,
                                    tooltip: 'Edit',
                                    color: theme.colorScheme.tertiary,
                                  ),
                                _buildIconButton(
                                  context,
                                  icon: Icons.delete_outline,
                                  onPressed: () => _showDeleteDialog(context),
                                  tooltip: 'Delete',
                                  color: theme.colorScheme.error,
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
          ),
        );
      },
    );
  }

  Widget _buildDocumentPreview(BuildContext context, ThemeData theme) {
    if (widget.document.isPdf) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red.withValues(alpha: 0.1),
              Colors.red.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.picture_as_pdf,
                size: 48.sp,
                color: Colors.red,
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'PDF',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        child: widget.document.imageFile.existsSync()
            ? Image.file(
                widget.document.imageFile,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorWidget(theme);
                },
              )
            : _buildErrorWidget(theme),
      );
    }
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Container(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 40.sp,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: 8.h),
            Text(
              'Image not found',
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    required Color color,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.all(6.w),
            child: Icon(
              icon,
              size: 18.sp,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  String _getDisplayName() {
    String name = widget.document.title ?? widget.document.fileName;
    if (name.length > 20) {
      return '${name.substring(0, 17)}...';
    }
    return name;
  }

  String _getFileInfo() {
    final extension = widget.document.isPdf ? 'PDF' : 'JPG';
    final date = DateTime.now().difference(widget.document.createdAt);
    String timeAgo;
    
    if (date.inDays > 0) {
      timeAgo = '${date.inDays}d ago';
    } else if (date.inHours > 0) {
      timeAgo = '${date.inHours}h ago';
    } else if (date.inMinutes > 0) {
      timeAgo = '${date.inMinutes}m ago';
    } else {
      timeAgo = 'Just now';
    }
    
    return '$extension • $timeAgo';
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              const Text('Delete Document'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${widget.document.title ?? widget.document.fileName}"? This action cannot be undone.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDelete();
              },
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
