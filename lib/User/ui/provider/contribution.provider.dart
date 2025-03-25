import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_heritedge/User/ui/repository/google.api.handler.dart';


class ContributionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleDriveHelper _driveHelper = GoogleDriveHelper();

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
    String? primaryImageUrl = await _driveHelper.uploadImage(primaryImage);

    // Upload Secondary Images
    List<String> secondaryImageUrls = [];
    for (var image in secondaryImages) {
      String? imageUrl = await _driveHelper.uploadImage(image);
      if (imageUrl != null) {
        secondaryImageUrls.add(imageUrl);
      }
    }

    if (primaryImageUrl != null) {
      // Debugging Logs
      print("Upload Success: Primary Image: $primaryImageUrl");
      print("Upload Success: Secondary Images: $secondaryImageUrls");

      // Save to Firestore
      await _firestore.collection('heritage_sites').add({
        'siteName': siteName,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'primaryImage': primaryImageUrl,
        'secondaryImages': secondaryImageUrls,
        'isPending': true, 
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Firestore Data Saved Successfully!");
    } else {
      print("Error: Primary image URL is null!");
    }
  } catch (e) {
    print("Firestore Save Error: $e");
  }

  _isLoading = false;
  notifyListeners();
      }
}