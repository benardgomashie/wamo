import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery
  Future<List<XFile>?> pickMultipleImages({int maxImages = 5}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (images.length > maxImages) {
        return images.sublist(0, maxImages);
      }
      
      return images;
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return null;
    }
  }

  /// Upload image to Firebase Storage
  Future<String?> uploadImage({
    required String filePath,
    required String storagePath,
    Function(double)? onProgress,
  }) async {
    try {
      final File file = File(filePath);
      
      // Check file size (max 2MB)
      final int fileSize = await file.length();
      if (fileSize > 2 * 1024 * 1024) {
        throw Exception('File size exceeds 2MB limit');
      }

      final Reference ref = _storage.ref().child(storagePath);
      final UploadTask uploadTask = ref.putFile(file);

      // Listen to upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  /// Upload multiple images
  Future<List<String>> uploadMultipleImages({
    required List<String> filePaths,
    required String folderPath,
    Function(int, double)? onProgress,
  }) async {
    final List<String> downloadUrls = [];

    for (int i = 0; i < filePaths.length; i++) {
      final String filePath = filePaths[i];
      final String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final String storagePath = '$folderPath/$fileName';

      try {
        final String? url = await uploadImage(
          filePath: filePath,
          storagePath: storagePath,
          onProgress: (progress) {
            if (onProgress != null) {
              onProgress(i, progress);
            }
          },
        );

        if (url != null) {
          downloadUrls.add(url);
        }
      } catch (e) {
        debugPrint('Error uploading image $i: $e');
        // Continue with other images even if one fails
      }
    }

    return downloadUrls;
  }

  /// Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting image: $e');
      rethrow;
    }
  }

  /// Delete multiple images
  Future<void> deleteMultipleImages(List<String> imageUrls) async {
    for (final String url in imageUrls) {
      try {
        await deleteImage(url);
      } catch (e) {
        debugPrint('Error deleting image $url: $e');
        // Continue with other images
      }
    }
  }

  /// Get image size in bytes
  Future<int> getImageSize(String filePath) async {
    final File file = File(filePath);
    return await file.length();
  }

  /// Format file size for display
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
