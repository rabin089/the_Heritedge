import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_heritedge/Common/widgets/widget.heritage.card.dart';
import 'package:geolocator/geolocator.dart';

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

class HeritageNameSearchDelegate extends SearchDelegate<DocumentSnapshot?> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> _searchSitesByName(String pattern) async {
    final snapshot = await firestore.collection('heritage_sites').get();
    return snapshot.docs.where((doc) {
      final name = (doc.data()['name'] ?? '').toString();
      return linearSearch(name, pattern);
    }).toList();
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<Position>(
      future: _getCurrentLocation(),
      builder: (context, locSnapshot) {
        if (locSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!locSnapshot.hasData) {
          return Center(child: Text('Could not get location.'));
        }

        final userLat = locSnapshot.data!.latitude;
        final userLng = locSnapshot.data!.longitude;

        return FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
          future: _searchSitesByName(query),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No heritage sites found.'));
            }

            final filteredSites = snapshot.data!;
            return ListView.builder(
              itemCount: filteredSites.length,
              itemBuilder: (context, index) {
                return HeritageResultCard(
                  doc: filteredSites[index],
                  userLat: userLat,
                  userLng: userLng,
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
      child: Text('Search heritage sites by name.'),
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
