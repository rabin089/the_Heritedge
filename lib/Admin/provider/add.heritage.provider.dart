import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../User/ui/services/imgbb.services.dart'; // Adjust path as needed

class AdminHeritageProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImgBBService _imgBBService = ImgBBService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> addHeritageByAdmin({
    required String siteName,
    required String description,
    required String category,
    required String region,
    required String location,
    required String latitude,
    required String longitude,
    required List<String> tags,
    required File primaryImage,
    required List<File> secondaryImages,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Upload primary image
      String? primaryImageUrl = await _imgBBService.uploadImage(primaryImage);

      // Upload secondary images
      List<String> secondaryImageUrls = [];
      for (var image in secondaryImages) {
        String? imageUrl = await _imgBBService.uploadImage(image);
        if (imageUrl != null) {
          secondaryImageUrls.add(imageUrl);
        }
      }

      if (primaryImageUrl != null) {
        // Add document to Firestore
        await _firestore.collection('heritage_sites').add({
          'name': siteName,
          'description': description,
          'category': category,
          'region': region,
          'location': location,
          'latitude': latitude,
          'longitude': longitude,
          'tags': tags,
          'imageUrl': primaryImageUrl,
          'secondaryImages': secondaryImageUrls,
          'isPending': false, // ✅ Admin always sets isPending to false
          'timestamp': FieldValue.serverTimestamp(),
        });

        print("Admin heritage site submission successful.");
      } else {
        throw Exception("Primary image upload failed.");
      }
    } catch (e) {
      print("Admin submission error: $e");
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }
}
