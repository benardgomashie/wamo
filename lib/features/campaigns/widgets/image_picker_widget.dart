import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme.dart';
import '../../../core/services/storage_service.dart';

class ImagePickerWidget extends StatefulWidget {
  final List<String> initialImages;
  final Function(List<String>) onImagesChanged;
  final int maxImages;
  final String uploadPath;
  
  const ImagePickerWidget({
    super.key,
    this.initialImages = const [],
    required this.onImagesChanged,
    this.maxImages = 5,
    required this.uploadPath,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final StorageService _storageService = StorageService();
  final List<String> _imageUrls = [];
  final List<XFile> _localImages = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _imageUrls.addAll(widget.initialImages);
  }

  Future<void> _pickImages() async {
    if (_imageUrls.length + _localImages.length >= widget.maxImages) {
      _showError('Maximum ${widget.maxImages} images allowed');
      return;
    }

    final remainingSlots = widget.maxImages - (_imageUrls.length + _localImages.length);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final images = await _storageService.pickMultipleImages(
                  maxImages: remainingSlots,
                );
                if (images != null && images.isNotEmpty) {
                  setState(() {
                    _localImages.addAll(images);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final image = await _storageService.pickImageFromCamera();
                if (image != null) {
                  setState(() {
                    _localImages.add(image);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadImages() async {
    if (_localImages.isEmpty) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final filePaths = _localImages.map((img) => img.path).toList();
      final urls = await _storageService.uploadMultipleImages(
        filePaths: filePaths,
        folderPath: widget.uploadPath,
        onProgress: (index, progress) {
          setState(() {
            _uploadProgress = (index + progress) / _localImages.length;
          });
        },
      );

      setState(() {
        _imageUrls.addAll(urls);
        _localImages.clear();
        _isUploading = false;
      });

      widget.onImagesChanged(_imageUrls);
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showError('Failed to upload images: $e');
    }
  }

  void _removeImage(int index, {bool isLocal = false}) {
    setState(() {
      if (isLocal) {
        _localImages.removeAt(index);
      } else {
        _imageUrls.removeAt(index);
        widget.onImagesChanged(_imageUrls);
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalImages = _imageUrls.length + _localImages.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Proof Images',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$totalImages/${widget.maxImages}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppTheme.spacingS),
        
        Text(
          'Upload images that support your campaign (receipts, documents, photos)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        
        const SizedBox(height: AppTheme.spacingM),
        
        // Image grid
        if (totalImages > 0)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppTheme.spacingS,
              mainAxisSpacing: AppTheme.spacingS,
            ),
            itemCount: totalImages,
            itemBuilder: (context, index) {
              final isLocal = index >= _imageUrls.length;
              final localIndex = index - _imageUrls.length;
              
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      child: isLocal
                          ? Image.file(
                              File(_localImages[localIndex].path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Image.network(
                              _imageUrls[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(
                        isLocal ? localIndex : index,
                        isLocal: isLocal,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        
        const SizedBox(height: AppTheme.spacingM),
        
        // Upload progress
        if (_isUploading)
          Column(
            children: [
              LinearProgressIndicator(value: _uploadProgress),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
            ],
          ),
        
        // Action buttons
        Row(
          children: [
            if (totalImages < widget.maxImages)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isUploading ? null : _pickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Images'),
                ),
              ),
            
            if (_localImages.isNotEmpty) ...[
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadImages,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Upload'),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
