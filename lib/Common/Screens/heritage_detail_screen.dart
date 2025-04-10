import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HeritageDetailScreen extends StatelessWidget {
  final Map<String, dynamic> site;
  final String? id;

  HeritageDetailScreen({required this.site, this.id});

  void _openGoogleMaps(Map<String, dynamic> site) async {
    final String latitude = site["latitude"]?.toString() ?? "0.0";
    final String longitude = site["longitude"]?.toString() ?? "0.0";

    final Uri googleMapsUri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude",
    );

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch Google Maps.");
    }
  }

  void _openGoogleMapsDirections(Map<String, dynamic> site) async {
    final String latitude = site["latitude"]?.toString() ?? "0.0";
    final String longitude = site["longitude"]?.toString() ?? "0.0";

    final Uri googleMapsUri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving",
    );

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch directions.");
    }
  }

  @override
  Widget build(BuildContext context) {
    String name = site["name"] ?? "No Name Available";
    String location = site["location"] ?? "Location Unknown";
    String description = site["description"] ?? "No Description Available";
    String imageUrl = site["imageUrl"] ?? "";
    String latitude = site["latitude"]?.toString() ?? "Unknown";
    String longitude = site["longitude"]?.toString() ?? "Unknown";

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl.isNotEmpty
                ? Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/placeholder.jpg",
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    );
                  },
                )
                : Image.asset(
                  "assets/placeholder.jpg",
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red),
                      SizedBox(width: 5),
                      Text(location, style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(description, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.map, color: Colors.blue),
                      SizedBox(width: 5),
                      Text(
                        "Lat: $latitude, Long: $longitude",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  /// View on Google Map
                  ElevatedButton.icon(
                    icon: Icon(Icons.map_outlined),
                    label: Text("View on Google Maps"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _openGoogleMaps(site),
                  ),
                  SizedBox(height: 10),

                  /// Get Directions
                  ElevatedButton.icon(
                    icon: Icon(Icons.directions),
                    label: Text("Get Directions"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _openGoogleMapsDirections(site),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
