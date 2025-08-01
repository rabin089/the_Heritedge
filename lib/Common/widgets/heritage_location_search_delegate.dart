import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:the_heritedge/Common/widgets/widget.heritage.card.dart';
import '../utility/distance.calculator.utils.dart';

bool linearSearch(String text, String pattern) {
  int n = text.length;
  int m = pattern.length;

  for (int i = 0; i <= n - m; i++) {
    int j = 0;
    while (j < m && text[i + j].toLowerCase() == pattern[j].toLowerCase()) {
      j++;
    }
    if (j == m) {
      return true;
    }
  }
  return false;
}

class HeritageLocationSearchDelegate extends SearchDelegate<DocumentSnapshot?> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  double? _searchLatitude;
  double? _searchLongitude;

  HeritageLocationSearchDelegate({required dynamic userLocation}) {
    _searchLatitude = userLocation.latitude;
    _searchLongitude = userLocation.longitude;
  }

  Future<Map<String, double>?> _getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        return {
          'latitude': loc.latitude,
          'longitude': loc.longitude,
        };
      }
    } catch (_) {}
    return null;
  }

  Stream<List<DocumentSnapshot<Map<String, dynamic>>>> _getNearbySites() {
    if (_searchLatitude == null || _searchLongitude == null) {
      return Stream.value([]);
    }

    return firestore.collection('heritage_sites').snapshots().map((snapshot) {
      List<DocumentSnapshot<Map<String, dynamic>>> nearbySites = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['latitude'] != null && data['longitude'] != null) {
          try {
            final lat = double.parse(data['latitude'].toString());
            final lng = double.parse(data['longitude'].toString());

            final distance = calculateDistance(
              _searchLatitude!,
              _searchLongitude!,
              lat,
              lng,
            );

            if (distance <= 5) {
              nearbySites.add(doc);
            }
          } catch (_) {}
        }
      }

      nearbySites.sort((a, b) {
        final latA = double.parse(a.data()!['latitude'].toString());
        final lngA = double.parse(a.data()!['longitude'].toString());
        final latB = double.parse(b.data()!['latitude'].toString());
        final lngB = double.parse(b.data()!['longitude'].toString());

        final distanceA = calculateDistance(_searchLatitude!, _searchLongitude!, latA, lngA);
        final distanceB = calculateDistance(_searchLatitude!, _searchLongitude!, latB, lngB);

        return distanceA.compareTo(distanceB);
      });

      return nearbySites;
    });
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<Map<String, double>?>(
      future: _getCoordinatesFromAddress(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: Text('Could not find location.'));
        }

        _searchLatitude = snapshot.data!['latitude'];
        _searchLongitude = snapshot.data!['longitude'];

        return StreamBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
          stream: _getNearbySites(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No heritage sites found.'));
            }

            List<DocumentSnapshot<Map<String, dynamic>>> filteredSites = snapshot.data!;

            if (query.contains(' ')) {
              final nameQuery = query.split(' ').skip(1).join(' ');
              filteredSites = filteredSites.where((doc) {
                final name = (doc.data()?['name'] ?? '').toString();
                return linearSearch(name, nameQuery);
              }).toList();
            }

            return ListView.builder(
              itemCount: filteredSites.length,
              itemBuilder: (context, index) {
                return HeritageResultCard(
                  doc: filteredSites[index],
                  userLat: _searchLatitude!,
                  userLng: _searchLongitude!,
                  allSites: filteredSites,
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text('Search by location name, e.g., "Kathmandu".'),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }
}
