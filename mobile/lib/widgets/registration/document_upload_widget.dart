import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/constants.dart';

class DocumentUploadWidget extends StatefulWidget {
  final String documentType;
  final String title;
  final String description;
  final File? currentFile;
  final bool isRequired;
  final List<String> allowedExtensions;
  final int maxFileSizeBytes;
  final void Function(File?)? onFileSelected;
  final void Function()? onFileRemoved;
  final String? error;
  final bool isLoading;
  final bool enabled;

  const DocumentUploadWidget({
    Key? key,
    required this.documentType,
    required this.title,
    required this.description,
    this.currentFile,
    this.isRequired = false,
    this.allowedExtensions = const ['jpg', 'jpeg', 'png', 'pdf'],
    this.maxFileSizeBytes = 10485760, // 10MB
    this.onFileSelected,
    this.onFileRemoved,
    this.error,
    this.isLoading = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<DocumentUploadWidget> createState() => _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends State<DocumentUploadWidget> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (widget.isRequired) ...[
                            const SizedBox(width: 4),
                            Text(
                              '*',
                              style: TextStyle(
                                color: colorScheme.error,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _getDocumentIcon(),
                  color: colorScheme.primary,
                  size: 24,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // File status or upload area
            if (widget.currentFile != null)
              _buildFilePreview(theme, colorScheme)
            else
              _buildUploadArea(theme, colorScheme),

            // Error message
            if (widget.error != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.error != null
              ? colorScheme.error
              : colorScheme.outline.withOpacity(0.5),
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.surface,
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 48,
            color: widget.enabled
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Upload ${widget.title}',
            style: theme.textTheme.titleSmall?.copyWith(
              color: widget.enabled
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to select file or take photo',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: widget.enabled
                  ? colorScheme.onSurface.withOpacity(0.7)
                  : colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Supported formats: ${widget.allowedExtensions.join(', ').toUpperCase()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Max size: ${_formatFileSize(widget.maxFileSizeBytes)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.isLoading)
            const CircularProgressIndicator()
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: widget.enabled ? _selectFromGallery : null,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: widget.enabled ? _takePhoto : null,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFilePreview(ThemeData theme, ColorScheme colorScheme) {
    final fileName = widget.currentFile!.path.split('/').last;
    final fileSize = widget.currentFile!.lengthSync();
    final isImage = _isImageFile(fileName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          widget.currentFile!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image,
                              color: colorScheme.primary,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.description,
                        color: colorScheme.primary,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatFileSize(fileSize),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.enabled ? _removeFile : null,
                icon: Icon(
                  Icons.close,
                  color: colorScheme.error,
                ),
                tooltip: 'Remove file',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'File uploaded successfully',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: widget.enabled ? _replaceFile : null,
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Replace file'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon() {
    switch (widget.documentType) {
      case 'medical_license':
        return Icons.verified_user;
      case 'education_certificate':
        return Icons.school;
      case 'identity_document':
        return Icons.badge;
      case 'proof_of_address':
        return Icons.home;
      case 'insurance_card':
        return Icons.medical_services;
      default:
        return Icons.description;
    }
  }

  bool _isImageFile(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png'].contains(extension);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _selectFromGallery() async {
    try {
      // Request storage/photos permission
      final permissionGranted = await _requestStoragePermission();
      if (!permissionGranted) {
        _showError('Storage permission is required to select files');
        return;
      }

      // Check if we should use image picker or file picker
      final hasImageExtensions = widget.allowedExtensions
          .any((ext) => ['jpg', 'jpeg', 'png'].contains(ext.toLowerCase()));

      if (hasImageExtensions && widget.allowedExtensions.length <= 3) {
        // Use image picker for image-only selection
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );

        if (image != null) {
          final file = File(image.path);
          await _validateAndSelectFile(file);
        }
      } else {
        // Use file picker for mixed file types
        final FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: widget.allowedExtensions,
          allowMultiple: false,
        );

        if (result != null && result.files.isNotEmpty) {
          final file = File(result.files.first.path!);
          await _validateAndSelectFile(file);
        }
      }
    } catch (e) {
      _showError('Error selecting file: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      // Request camera permission
      final permissionGranted = await _requestCameraPermission();
      if (!permissionGranted) {
        _showError('Camera permission is required to take photos');
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        await _validateAndSelectFile(file);
      }
    } catch (e) {
      _showError('Error taking photo: $e');
    }
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      // Show dialog to open app settings
      final shouldOpenSettings = await _showPermissionDialog(
        'Camera Permission Required',
        'Camera access is required to take photos. Please enable it in app settings.',
      );
      
      if (shouldOpenSettings) {
        await openAppSettings();
      }
      return false;
    }
    
    return false;
  }

  Future<bool> _requestStoragePermission() async {
    // For Android 13+ (API 33+), we need to request photos permission
    // For older versions, we need storage permission
    Permission permission;
    
    if (Platform.isAndroid) {
      // Check Android version - use photos for Android 13+
      permission = Permission.photos;
      
      // Fallback to storage for older Android versions
      final photosStatus = await permission.status;
      if (photosStatus.isPermanentlyDenied || photosStatus.isRestricted) {
        permission = Permission.storage;
      }
    } else if (Platform.isIOS) {
      permission = Permission.photos;
    } else {
      // For other platforms, assume permission is granted
      return true;
    }
    
    final status = await permission.status;
    
    if (status.isGranted || status.isLimited) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted || result.isLimited;
    }
    
    if (status.isPermanentlyDenied) {
      // Show dialog to open app settings
      final shouldOpenSettings = await _showPermissionDialog(
        'Storage Permission Required',
        'Storage access is required to select files. Please enable it in app settings.',
      );
      
      if (shouldOpenSettings) {
        await openAppSettings();
      }
      return false;
    }
    
    return false;
  }

  Future<bool> _showPermissionDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  Future<void> _validateAndSelectFile(File file) async {
    try {
      // Check file size
      final fileSize = await file.length();
      if (fileSize > widget.maxFileSizeBytes) {
        _showError('File size is too large. Maximum size is ${_formatFileSize(widget.maxFileSizeBytes)}');
        return;
      }

      // Check file extension
      final fileName = file.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();
      if (!widget.allowedExtensions.contains(extension)) {
        _showError('Unsupported file type. Allowed types: ${widget.allowedExtensions.join(', ').toUpperCase()}');
        return;
      }

      widget.onFileSelected?.call(file);
    } catch (e) {
      _showError('Error validating file: $e');
    }
  }

  void _removeFile() {
    widget.onFileRemoved?.call();
  }

  void _replaceFile() {
    _selectFromGallery();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

// Batch upload widget for multiple documents
class BatchDocumentUpload extends StatelessWidget {
  final List<DocumentUploadConfig> documents;
  final Map<String, File> selectedFiles;
  final Map<String, String> errors;
  final Set<String> loadingDocuments;
  final void Function(String documentType, File file)? onFileSelected;
  final void Function(String documentType)? onFileRemoved;
  final bool enabled;

  const BatchDocumentUpload({
    Key? key,
    required this.documents,
    required this.selectedFiles,
    this.errors = const {},
    this.loadingDocuments = const {},
    this.onFileSelected,
    this.onFileRemoved,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: documents.map((config) {
        return DocumentUploadWidget(
          documentType: config.type,
          title: config.title,
          description: config.description,
          currentFile: selectedFiles[config.type],
          isRequired: config.isRequired,
          allowedExtensions: config.allowedExtensions,
          maxFileSizeBytes: config.maxFileSizeBytes,
          error: errors[config.type],
          isLoading: loadingDocuments.contains(config.type),
          enabled: enabled,
          onFileSelected: (file) => onFileSelected?.call(config.type, file!),
          onFileRemoved: () => onFileRemoved?.call(config.type),
        );
      }).toList(),
    );
  }
}

class DocumentUploadConfig {
  final String type;
  final String title;
  final String description;
  final bool isRequired;
  final List<String> allowedExtensions;
  final int maxFileSizeBytes;

  const DocumentUploadConfig({
    required this.type,
    required this.title,
    required this.description,
    this.isRequired = false,
    this.allowedExtensions = const ['jpg', 'jpeg', 'png', 'pdf'],
    this.maxFileSizeBytes = 10485760, // 10MB
  });
}
