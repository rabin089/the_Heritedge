import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class HeritageService {
  final CollectionReference _heritageCollection =
  FirebaseFirestore.instance.collection('heritage_sites');

  Future<List<Map<String, dynamic>>> fetchHeritageSites() async {
    try {
      debugPrint("Fetching approved heritage sites from Firestore...");

      QuerySnapshot querySnapshot = await _heritageCollection
          .where('isPending', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint("No approved heritage sites found.");
        return [];
      }

      List<Map<String, dynamic>> heritageSites = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        debugPrint("Processing document ID: ${doc.id}");

        // Standardize image URL field (handle both 'imageUrl' and 'imageurl')
        String? imageUrl = _getValidImageUrl(data);

        // Clean and validate all data before returning
        return {
          "id": doc.id,
          "name": data["name"]?.toString().trim() ?? "Unnamed Site",
          "location": data["location"]?.toString().trim() ?? "Location not specified",
          "description": data["description"]?.toString().trim() ?? "No description available",
          "imageUrl": imageUrl, // This will be either valid URL or empty string
          "latitude": _parseDouble(data["latitude"]),
          "longitude": _parseDouble(data["longitude"]),
          "region": data["region"]?.toString().trim(),
          "category": data["category"]?.toString().trim(),
          "timestamp": data["timestamp"],
          "userId": data["userId"]?.toString() ?? "",
          // Add other fields as needed
        };
      }).toList();

      return heritageSites;
    } catch (e) {
      debugPrint("Error fetching heritage sites: $e");
      return [];
    }
  }

  // Helper method to get valid image URL
  String? _getValidImageUrl(Map<String, dynamic> data) {
    // Try both possible field names (case insensitive)
    String? url = data["imageUrl"] ?? data["imageurl"];

    // Convert to string if it's not null
    url = url?.toString().trim();

    // Validate URL format
    if (url == null || url.isEmpty) {
      debugPrint("Empty or null image URL for document");
      return null;
    }

    // Ensure URL has proper scheme
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      debugPrint("Invalid URL scheme: $url");
      return null;
    }

    return url;
  }

  // Helper method to safely parse double values
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}