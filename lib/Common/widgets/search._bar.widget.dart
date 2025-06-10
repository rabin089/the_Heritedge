import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import '../utility/distance.calculator.utils.dart';

class HeritageSearchDelegate extends SearchDelegate<DocumentSnapshot?> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  double? _searchLatitude;
  double? _searchLongitude;

  // Helper: Convert location name to coordinates
  Future<Map<String, double>?> _getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        print('Geocoded Location: ${loc.latitude}, ${loc.longitude}');
        return {
          'latitude': loc.latitude,
          'longitude': loc.longitude,
        };
      } else {
        print('No locations found for address: $address');
        return null;
      }
    } catch (e) {
      print('Geocoding error: $e');
      return null;
    }
  }

  // Returns a stream of documents within 50 km of search coordinates
  Stream<List<DocumentSnapshot<Map<String, dynamic>>>> _getNearbySites() {
    if (_searchLatitude == null || _searchLongitude == null) {
      return Stream.value([]);
    }

    print('Searching near: $_searchLatitude, $_searchLongitude');

    return firestore.collection('heritage_sites').snapshots().map((snapshot) {
      List<DocumentSnapshot<Map<String, dynamic>>> nearbySites = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // Check if latitude and longitude exist and are valid
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

            // Include sites within 50 km
            if (distance <= 50) {
              nearbySites.add(doc);
            }
          } catch (e) {
            print('Error parsing coordinates for ${doc.id}: $e');
          }
        }
      }

      // Sort by distance (closest first)
      nearbySites.sort((a, b) {
        final dataA = a.data()!;
        final dataB = b.data()!;

        final latA = double.parse(dataA['latitude'].toString());
        final lngA = double.parse(dataA['longitude'].toString());
        final latB = double.parse(dataB['latitude'].toString());
        final lngB = double.parse(dataB['longitude'].toString());

        final distanceA = calculateDistance(_searchLatitude!, _searchLongitude!, latA, lngA);
        final distanceB = calculateDistance(_searchLatitude!, _searchLongitude!, latB, lngB);

        return distanceA.compareTo(distanceB);
      });

      return nearbySites;
    });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search for Heritage Sites',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text(
            'Enter a location name to find heritage sites nearby (within 50 km).',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 16),
          Text(
            'You can search by:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8),
          Text('• City name (e.g., "Kathmandu")'),
          Text('• Region name (e.g., "Bagmati")'),
          Text('• Landmark (e.g., "Sundarijal")'),
        ],
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<Map<String, double>?>(
      future: _getCoordinatesFromAddress(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Finding location...'),
              ],
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Could not find location: "$query"',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8),
                Text(
                  'Please try a different search term.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        _searchLatitude = snapshot.data!['latitude'];
        _searchLongitude = snapshot.data!['longitude'];

        return StreamBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
          stream: _getNearbySites(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Searching for heritage sites...'),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No heritage sites found near "$query"',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Try searching for a different location.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            // Filter by site name if user wants to narrow down results
            List<DocumentSnapshot<Map<String, dynamic>>> filteredSites = snapshot.data!;

            // Optional: If user types additional text after location, filter by name
            if (query.contains(' ')) {
              List<String> queryParts = query.split(' ');
              if (queryParts.length > 1) {
                String nameQuery = queryParts.sublist(1).join(' ').toLowerCase();
                filteredSites = snapshot.data!.where((doc) {
                  final name = (doc.data()?['name'] ?? '').toString().toLowerCase();
                  return name.contains(nameQuery);
                }).toList();
              }
            }

            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Found ${filteredSites.length} heritage sites near "$query"',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredSites.length,
                    itemBuilder: (context, index) {
                      final doc = filteredSites[index];
                      final data = doc.data()!;

                      final lat = double.parse(data['latitude'].toString());
                      final lng = double.parse(data['longitude'].toString());
                      final distance = calculateDistance(
                        _searchLatitude!,
                        _searchLongitude!,
                        lat,
                        lng,
                      );

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                            ),
                            child: data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                data['imageUrl'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.landscape,
                                      color: Theme.of(context).primaryColor);
                                },
                              ),
                            )
                                : Icon(Icons.landscape,
                                color: Theme.of(context).primaryColor),
                          ),
                          title: Text(
                            data['name'] ?? 'Unknown Site',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${distance.toStringAsFixed(2)} km away'),
                              if (data['region'] != null && data['region'].toString().isNotEmpty)
                                Text('Region: ${data['region']}'),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            close(context, doc);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
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
            _searchLatitude = null;
            _searchLongitude = null;
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
