import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:the_heritedge/User/ui/provider/contribution.provider.dart';

class ContributionScreen extends StatefulWidget {
  @override
  _ContributionScreenState createState() => _ContributionScreenState();
}

class _ContributionScreenState extends State<ContributionScreen> {
  final TextEditingController _siteNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  File? _primaryImage;
  List<File> _secondaryImages = [];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickPrimaryImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
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
        _secondaryImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  void _submitContribution(BuildContext context) {
    // if (_siteNameController.text.isEmpty ||
    //     _descriptionController.text.isEmpty ||
    //     _latitudeController.text.isEmpty ||
    //     _longitudeController.text.isEmpty ||
    //     _primaryImage == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("Please fill all fields and select images")),
    //   );
    //   return;
    // }

    final provider = Provider.of<ContributionProvider>(context, listen: false);
    provider.submitContribution(
      siteName: _siteNameController.text,
      description: _descriptionController.text,
      latitude: _latitudeController.text,
      longitude:_longitudeController.text,
      primaryImage: _primaryImage!,
      secondaryImages: _secondaryImages,
    );

    // Clear fields after submission
    _siteNameController.clear();
    _descriptionController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
    setState(() {
      _primaryImage = null;
      _secondaryImages = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Contribution submitted successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ContributionProvider>(context);
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child:Scaffold(
      appBar: AppBar(title: Text("Contribute Heritage Site")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _siteNameController,
              decoration: InputDecoration(labelText: "Heritage Site Name"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _latitudeController,
              decoration: InputDecoration(labelText: "Latitude"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _longitudeController,
              decoration: InputDecoration(labelText: "Longitude"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),

            // Primary Image Picker
            Text("Primary Image", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _primaryImage != null
                ? Image.file(_primaryImage!, height: 150)
                : Text("No image selected"),
            ElevatedButton(
              onPressed: _pickPrimaryImage,
              child: Text("Select Primary Image"),
            ),
            
            SizedBox(height: 20),

            // Secondary Images Picker
            Text("Secondary Images", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _secondaryImages.isNotEmpty
                ? Wrap(
                    spacing: 10,
                    children: _secondaryImages.map((img) => Image.file(img, height: 80)).toList(),
                  )
                : Text("No images selected"),
            ElevatedButton(
              onPressed: _pickSecondaryImages,
              child: Text("Select Secondary Images"),
            ),

            SizedBox(height: 30),

            // Submit Button
            provider.isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () => _submitContribution(context),
                    child: Text("Submit Contribution"),
                  ),
          ],
        ),
      ),
      ),
    );
  }
}
