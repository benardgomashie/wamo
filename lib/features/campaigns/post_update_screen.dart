import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../../core/models/campaign.dart';

class PostUpdateScreen extends StatefulWidget {
  final Campaign campaign;

  const PostUpdateScreen({
    super.key,
    required this.campaign,
  });

  @override
  State<PostUpdateScreen> createState() => _PostUpdateScreenState();
}

class _PostUpdateScreenState extends State<PostUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _updateController = TextEditingController();
  final List<XFile> _selectedImages = [];
  bool _isLoading = false;
  bool _isPinned = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _updateController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
          if (_selectedImages.length > 5) {
            _selectedImages.removeRange(5, _selectedImages.length);
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<List<String>> _uploadImages() async {
    final List<String> imageUrls = [];

    for (int i = 0; i < _selectedImages.length; i++) {
      final XFile image = _selectedImages[i];
      final String fileName =
          'updates/${widget.campaign.id}/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

      final Reference ref = FirebaseStorage.instance.ref().child(fileName);
      final UploadTask uploadTask = ref.putFile(File(image.path));

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }

    return imageUrls;
  }

  Future<void> _postUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Upload images if any
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        imageUrls = await _uploadImages();
      }

      // Create update document
      await FirebaseFirestore.instance.collection('updates').add({
        'campaign_id': widget.campaign.id,
        'text': _updateController.text.trim(),
        'media_urls': imageUrls,
        'is_pinned': _isPinned,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Update campaign's updated_at timestamp
      await FirebaseFirestore.instance
          .collection('campaigns')
          .doc(widget.campaign.id)
          .update({
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Update posted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error posting update: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Update'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _postUpdate,
              child: const Text(
                'POST',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Campaign info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.campaign.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: widget.campaign.raisedAmount /
                          widget.campaign.targetAmount,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'GHS ${widget.campaign.raisedAmount.toStringAsFixed(0)} raised of GHS ${widget.campaign.targetAmount.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Update text
            TextFormField(
              controller: _updateController,
              maxLines: 8,
              maxLength: 1000,
              decoration: const InputDecoration(
                labelText: 'Share your progress',
                hintText:
                    'Let your supporters know how funds are being used, share receipts, or thank donors...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an update';
                }
                if (value.trim().length < 10) {
                  return 'Update must be at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Pin update option
            CheckboxListTile(
              value: _isPinned,
              onChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() => _isPinned = value ?? false);
                    },
              title: const Text('Pin this update'),
              subtitle: const Text('Pinned updates appear at the top'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // Image selection
            OutlinedButton.icon(
              onPressed: _isLoading || _selectedImages.length >= 5
                  ? null
                  : _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(
                _selectedImages.isEmpty
                    ? 'Add Photos (Optional)'
                    : 'Add More Photos (${_selectedImages.length}/5)',
              ),
            ),
            const SizedBox(height: 16),

            // Selected images
            if (_selectedImages.isNotEmpty) ...[
              const Text(
                'Selected Photos:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(_selectedImages[index].path),
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                            onPressed: () => _removeImage(index),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
            ],

            // Tips
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Tips for great updates',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Share specific progress (e.g., "Surgery scheduled for...")\n'
                      '• Include receipts or photos as proof\n'
                      '• Thank your donors personally\n'
                      '• Post regularly to keep supporters engaged',
                      style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
