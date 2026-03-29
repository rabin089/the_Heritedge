import 'package:cloud_firestore/cloud_firestore.dart';

class HeritageService {
  final CollectionReference _heritageCollection =
  FirebaseFirestore.instance.collection('heritage_sites'); // Ensure the correct collection name

  Future<List<Map<String, dynamic>>> fetchHeritageSites() async {
    try {
      print("Fetching data from Firestore..."); // Debugging print
      QuerySnapshot querySnapshot = await _heritageCollection.get(); // Fetch data once

      if (querySnapshot.docs.isEmpty) {
        print("No heritage sites found.");
        return [];
      }

      List<Map<String, dynamic>> heritageSites = querySnapshot.docs.map((doc) {
        print("Fetched document ID: ${doc.id}");
        print("Document data: ${doc.data()}"); // Debugging print

        return {
          "id": doc.id, // Store document ID for navigation
          "name": doc["name"] ?? "No Name",
          "location": doc["location"] ?? "Unknown Location",
          "description": doc["description"] ?? "No Description Available",
          "imageUrl": doc["imageurl"] ?? "",
          "latitude": doc["latitude"] ?? "0.0", // Handle missing data
          "longitude": doc["longitude"] ?? "0.0"
        };
      }).toList();

      return heritageSites;
    } catch (e) {
      print("Error fetching heritage sites: $e");
      return [];
    }
  }
}
