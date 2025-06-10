import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:the_heritedge/User/ui/provider/contribution.provider.dart';

import '../provider/add.heritage.provider.dart';

class AdminAddHeritageScreen extends StatefulWidget {
  const AdminAddHeritageScreen({super.key});

  @override
  State<AdminAddHeritageScreen> createState() => _AdminAddHeritageScreenState();
}

class _AdminAddHeritageScreenState extends State<AdminAddHeritageScreen> {
  final TextEditingController _siteNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  File? _primaryImage;
  List<File> _secondaryImages = [];

  String? _selectedCategory;
  String? _selectedRegion;

  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'Temple', 'Monument', 'Palace', 'Fort', 'Museum',
    'Archaeological Site', 'Religious Site', 'Cultural Heritage', 'Natural Heritage', 'Other'
  ];

  final List<String> _regions = [
    'Bagmati', 'Gandaki', 'Lumbini', 'Karnali', 'Sudurpashchim', 'Koshi', 'Madhesh'
  ];

  Future<void> _pickPrimaryImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _primaryImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickSecondaryImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _secondaryImages = pickedFiles.map((e) => File(e.path)).toList();
      });
    }
  }

  void _removeSecondaryImage(int index) {
    setState(() {
      _secondaryImages.removeAt(index);
    });
  }

  List<String> _parseTags(String text) {
    return text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  bool _validateForm() {
    if (_siteNameController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        _selectedCategory == null ||
        _selectedRegion == null ||
        _primaryImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields."), backgroundColor: Colors.red),
      );
      return false;
    }
    return true;
  }

  Future<void> _submitHeritage(BuildContext context) async {
    if (!_validateForm()) return;

    final provider = Provider.of<AdminHeritageProvider>(context, listen: false);

    try {
      final locations = await locationFromAddress(_locationController.text.trim());
      if (locations.isEmpty) throw Exception("Could not find coordinates");

      final latitude = locations.first.latitude.toString();
      final longitude = locations.first.longitude.toString();
      final tags = _parseTags(_tagsController.text);

      await provider.addHeritageByAdmin(
        siteName: _siteNameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory!,
        region: _selectedRegion!,
        location: _locationController.text.trim(),
        latitude: latitude,
        longitude: longitude,
        tags: tags,
        primaryImage: _primaryImage!,
        secondaryImages: _secondaryImages,
      );

      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Heritage site added successfully."), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _clearForm() {
    _siteNameController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _tagsController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedRegion = null;
      _primaryImage = null;
      _secondaryImages = [];
    });
  }

  @override
  void dispose() {
    _siteNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminHeritageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Heritage Site (Admin)"),
        backgroundColor: Color(0xFF6D4C41),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add New Heritage Site",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Help preserve our cultural heritage by adding information about heritage sites.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            Text(
              "Basic Information",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 10),

            TextField(
              controller: _siteNameController,
              decoration: InputDecoration(
                labelText: "Heritage Site Name *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            SizedBox(height: 15),

            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: "Description *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                hintText: "Describe the heritage site, its history, and significance...",
              ),
              maxLines: 4,
            ),
            SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: "Category *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            SizedBox(height: 20),

            Text(
              "Location Information",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: _selectedRegion,
              decoration: InputDecoration(
                labelText: "Region/Province *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.map),
              ),
              items: _regions
                  .map((region) => DropdownMenuItem(
                        value: region,
                        child: Text(region),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRegion = value;
                });
              },
            ),
            SizedBox(height: 15),

            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: "Specific Location *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.place),
                hintText: "e.g., Sundarijal, Kathmandu",
              ),
            ),
            SizedBox(height: 15),

            TextField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: "Tags (comma-separated)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
                hintText: "nature, trekking, cultural, temple",
              ),
            ),
            SizedBox(height: 20),

            Text(
              "Images",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 10),

            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Primary Image *",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    _primaryImage != null
                        ? Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _primaryImage!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          )
                        : Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image, size: 50, color: Colors.grey),
                                Text("No image selected"),
                              ],
                            ),
                          ),
                    ElevatedButton.icon(
                      onPressed: _pickPrimaryImage,
                      icon: Icon(Icons.add_photo_alternate),
                      label: Text("Add Primary Images"),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Secondary Images (Optional)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    _secondaryImages.isNotEmpty
                        ? Column(
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _secondaryImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(8),
                                  child: Image.file(
                                    _secondaryImages[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () =>
                                        _removeSecondaryImage(index),
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
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
                        SizedBox(height: 10),
                      ],
                    )
                        : Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.collections,
                              size: 40, color: Colors.grey),
                          Text("No images selected"),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _pickSecondaryImages,
                      icon: Icon(Icons.add_photo_alternate),
                      label: Text("Add Secondary Images"),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: provider.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () => _submitHeritage(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6D4C41),
                        foregroundColor: Colors.white,
                      ),
                      child: Text("Add Heritage Site", style: TextStyle(fontSize: 16)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
