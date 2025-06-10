import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../User/ui/services/imgbb.services.dart';

class EditHeritageSitePage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const EditHeritageSitePage({super.key, required this.docId, required this.data});

  @override
  State<EditHeritageSitePage> createState() => _EditHeritageSitePageState();
}

class _EditHeritageSitePageState extends State<EditHeritageSitePage> {
  late TextEditingController nameController;
  late TextEditingController locationController;
  late TextEditingController descriptionController;
  late TextEditingController categoryController;
  late TextEditingController regionController;
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;
  late List<TextEditingController> tagsControllers;
  late bool isPending;

  // Image handling
  String originalImageUrl = '';
  String currentImageUrl = '';
  File? selectedMainImage;
  List<String> originalSecondaryImages = [];
  List<String> currentSecondaryImageUrls = [];
  List<File?> selectedSecondaryImages = [];

  final ImagePicker _picker = ImagePicker();
  final ImgBBService _imgBBService = ImgBBService();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final data = widget.data;

    // Initialize text controllers
    nameController = TextEditingController(text: data['name'] ?? '');
    locationController = TextEditingController(text: data['location'] ?? '');
    descriptionController = TextEditingController(text: data['description'] ?? '');
    categoryController = TextEditingController(text: data['category'] ?? '');
    regionController = TextEditingController(text: data['region'] ?? '');
    latitudeController = TextEditingController(text: data['latitude']?.toString() ?? '');
    longitudeController = TextEditingController(text: data['longitude']?.toString() ?? '');

    // Initialize tags
    tagsControllers = (data['tags'] as List<dynamic>? ?? [])
        .map((tag) => TextEditingController(text: tag.toString()))
        .toList();

    isPending = data['isPending'] ?? false;

    // Initialize image URLs
    originalImageUrl = data['imageUrl'] ?? '';
    currentImageUrl = originalImageUrl;
    originalSecondaryImages = List<String>.from(data['secondaryImages'] ?? []);
    currentSecondaryImageUrls = List<String>.from(originalSecondaryImages);
    selectedSecondaryImages = List.filled(currentSecondaryImageUrls.length, null);
  }

  Future<void> _pickMainImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedMainImage = File(image.path);
      });
    }
  }

  Future<void> _pickSecondaryImage(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (index < selectedSecondaryImages.length) {
          selectedSecondaryImages[index] = File(image.path);
        }
      });
    }
  }

  void _addSecondaryImage() {
    setState(() {
      currentSecondaryImageUrls.add('');
      selectedSecondaryImages.add(null);
    });
  }

  void _removeSecondaryImage(int index) {
    setState(() {
      currentSecondaryImageUrls.removeAt(index);
      selectedSecondaryImages.removeAt(index);
    });
  }

  Future<void> _updateHeritageSite() async {
    setState(() {
      _isUploading = true;
    });

    try {
      // Upload main image if changed
      if (selectedMainImage != null) {
        final uploadedUrl = await _imgBBService.uploadImage(selectedMainImage!);
        if (uploadedUrl != null) {
          currentImageUrl = uploadedUrl;
        }
      }

      // Upload secondary images if changed
      for (int i = 0; i < selectedSecondaryImages.length; i++) {
        if (selectedSecondaryImages[i] != null) {
          final uploadedUrl = await _imgBBService.uploadImage(selectedSecondaryImages[i]!);
          if (uploadedUrl != null) {
            currentSecondaryImageUrls[i] = uploadedUrl;
          }
        }
      }

      // Update Firestore document
      await FirebaseFirestore.instance
          .collection('heritage_sites')
          .doc(widget.docId)
          .update({
        'name': nameController.text.trim(),
        'location': locationController.text.trim(),
        'description': descriptionController.text.trim(),
        'category': categoryController.text.trim(),
        'region': regionController.text.trim(),
        'latitude': latitudeController.text.trim(),
        'longitude': longitudeController.text.trim(),
        'imageUrl': currentImageUrl,
        'secondaryImages': currentSecondaryImageUrls.where((url) => url.isNotEmpty).toList(),
        'tags': tagsControllers.map((c) => c.text.trim()).where((tag) => tag.isNotEmpty).toList(),
        'isPending': isPending,
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating site: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Widget _buildImagePicker({
    required String label,
    required String currentUrl,
    required File? selectedImage,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: selectedImage != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(selectedImage, fit: BoxFit.cover),
            )
                : currentUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(currentUrl, fit: BoxFit.cover),
            )
                : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 40),
                  Text('Tap to select image'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold)),
        ...tagsControllers.asMap().entries.map((entry) {
          int idx = entry.key;
          return Row(
            children: [
              Expanded(
                child: TextField(
                  controller: entry.value,
                  decoration: InputDecoration(labelText: 'Tag ${idx + 1}'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    tagsControllers.removeAt(idx);
                  });
                },
              ),
            ],
          );
        }),
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Tag'),
          onPressed: () {
            setState(() {
              tagsControllers.add(TextEditingController());
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF795548),
        title: const Text('Edit Heritage Site'),
        actions: [
          IconButton(
            icon: _isUploading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Icon(Icons.save),
            onPressed: _isUploading ? null : _updateHeritageSite,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 16),
            TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
            const SizedBox(height: 16),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
            const SizedBox(height: 16),
            TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
            const SizedBox(height: 16),
            TextField(controller: regionController, decoration: const InputDecoration(labelText: 'Region')),
            const SizedBox(height: 16),
            TextField(controller: latitudeController, decoration: const InputDecoration(labelText: 'Latitude')),
            const SizedBox(height: 16),
            TextField(controller: longitudeController, decoration: const InputDecoration(labelText: 'Longitude')),
            const SizedBox(height: 16),

            // Main Image
            _buildImagePicker(
              label: 'Main Image',
              currentUrl: currentImageUrl,
              selectedImage: selectedMainImage,
              onTap: _pickMainImage,
            ),
            const SizedBox(height: 16),

            // Secondary Images
            const Text('Secondary Images', style: TextStyle(fontWeight: FontWeight.bold)),
            ...currentSecondaryImageUrls.asMap().entries.map((entry) {
              int idx = entry.key;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildImagePicker(
                        label: 'Secondary Image ${idx + 1}',
                        currentUrl: entry.value,
                        selectedImage: selectedSecondaryImages[idx],
                        onTap: () => _pickSecondaryImage(idx),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeSecondaryImage(idx),
                    ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Secondary Image'),
              onPressed: _addSecondaryImage,
            ),
            const SizedBox(height: 16),

            // Tags
            _buildTagsList(),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Approved'),
              value: !isPending, // Note: isPending false means approved
              onChanged: (value) {
                setState(() {
                  isPending = !value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _updateHeritageSite,
              child: _isUploading
                  ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Updating...'),
                ],
              )
                  : const Text('Update Site'),
            ),
          ],
        ),
      ),
    );
  }
}
