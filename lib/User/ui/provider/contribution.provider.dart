import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/imgbb.services.dart';

class ContributionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImgBBService _imgBBService = ImgBBService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> submitContribution({
    required String siteName,
    required String description,
    required String latitude,
    required String longitude,
    required File primaryImage,
    required List<File> secondaryImages,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Upload Primary Image
      String? primaryImageUrl = await _imgBBService.uploadImage(primaryImage);

      // Upload Secondary Images
      List<String> secondaryImageUrls = [];
      for (var image in secondaryImages) {
        String? imageUrl = await _imgBBService.uploadImage(image);
        if (imageUrl != null) {
          secondaryImageUrls.add(imageUrl);
        }
      }

      if (primaryImageUrl != null) {
        print("Primary Image Uploaded: $primaryImageUrl");
        print("Secondary Images Uploaded: $secondaryImageUrls");

        // Save to Firestore
        await _firestore.collection('heritage_sites').add({
          'name': siteName,
          'description': description,
          'latitude': latitude,
          'longitude': longitude,
          'imageUrl': primaryImageUrl,
          'secondaryImages': secondaryImageUrls,
          'isPending': true,
          'timestamp': FieldValue.serverTimestamp(),
        });

        print("Firestore Data Saved Successfully!");
      } else {
        print("Error: Primary image upload failed.");
      }
    } catch (e) {
      print("Error Saving to Firestore: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
