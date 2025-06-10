import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0;
  double toRadians(double degree) => degree * pi / 180;

  final dLat = toRadians(lat2 - lat1);
  final dLon = toRadians(lon2 - lon1);

  final lat1Rad = toRadians(lat1);
  final lat2Rad = toRadians(lat2);

  final a = pow(sin(dLat / 2), 2) +
      cos(lat1Rad) * cos(lat2Rad) * pow(sin(dLon / 2), 2);

  final c = 2 * asin(sqrt(a));
  return earthRadiusKm * c;
}

class HeritageService {
  Future<List<Map<String, dynamic>>> filterHeritageSitesFromFirestore({
    required String region,
    required String category,
    required List<String> tags,
    required double userLat,
    required double userLon,
    double maxDistanceKm = 50,
  }) async {
    Query query = FirebaseFirestore.instance.collection('heritage_sites');

    if (region != "All") {
      query = query.where('region', isEqualTo: region);
    }

    if (category != "All") {
      query = query.where('category', isEqualTo: category);
    }

    if (tags.isNotEmpty) {
      query = query.where('tags', arrayContainsAny: tags);
    }

    final snapshot = await query.get();
    final all = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    // Apply distance filter
    final filtered = all.where((site) {
      if (!site.containsKey('latitude') || !site.containsKey('longitude')) return false;

      final lat = site['latitude']?.toDouble();
      final lon = site['longitude']?.toDouble();

      if (lat == null || lon == null) return false;

      final distance = calculateDistance(userLat, userLon, lat, lon);
      return distance <= maxDistanceKm;
    }).toList();

    return filtered;
  }

  Future<List<Map<String, dynamic>>> fetchHeritageSites() async {
    final snapshot = await FirebaseFirestore.instance.collection('heritage_sites').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}
