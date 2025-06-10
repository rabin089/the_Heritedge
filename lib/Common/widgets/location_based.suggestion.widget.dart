import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../Screens/heritage_detail_screen.dart';

class SuggestedHeritageWidget extends StatefulWidget {
  final List<Map<String, dynamic>> sites;
  final Position userPosition;

  const SuggestedHeritageWidget({
    required this.sites,
    required this.userPosition,
    super.key,
  });

  @override
  State<SuggestedHeritageWidget> createState() => _SuggestedHeritageWidgetState();
}

class _SuggestedHeritageWidgetState extends State<SuggestedHeritageWidget> {
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Add computed distance to each site
    List<Map<String, dynamic>> nearbySites = widget.sites
        .map((site) {
      double lat = double.tryParse(site['latitude'].toString()) ?? 0.0;
      double lng = double.tryParse(site['longitude'].toString()) ?? 0.0;

      double distance = Geolocator.distanceBetween(
        widget.userPosition.latitude,
        widget.userPosition.longitude,
        lat,
        lng,
      );

      return {
        ...site,
        'distanceFromUser': distance,
      };
    })
        .where((site) => site['distanceFromUser'] <= 20000) // within 20km
        .toList();

    // Sort by distance (ascending)
    nearbySites.sort((a, b) => a['distanceFromUser'].compareTo(b['distanceFromUser']));

    if (nearbySites.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No nearby sites found',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Heritage Near You",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: nearbySites.length,
            itemBuilder: (context, index) {
              var site = nearbySites[index];
              String? imageUrl = site['imageUrl'] ?? site['imageurl'];
              bool hasValidImage = imageUrl != null && imageUrl.isNotEmpty && imageUrl.startsWith('http');

              return Container(
                width: 160,
                margin: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HeritageDetailScreen(site: site),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: hasValidImage
                              ? Image.network(
                            imageUrl!,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Image load error: $error');
                              debugPrint('URL: $imageUrl');
                              return Container(
                                height: 120,
                                color: Colors.grey[300],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.image_not_supported, size: 50),
                                    Text('Failed to load image', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              );
                            },
                          )
                              : Container(
                            height: 120,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image, size: 50, color: Colors.grey),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Column(
                            children: [
                              Text(
                                site['name'] ?? "Unknown",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                site['location'] ?? 'Location not specified',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(site['distanceFromUser'] / 1000).toStringAsFixed(2)} km away',
                                style: TextStyle(fontSize: 12, color: Colors.brown[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
