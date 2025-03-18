import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HeritageDetailScreen extends StatelessWidget {
  final Map<String, dynamic> site;
  final String? id;  // Ensure id is nullable

  HeritageDetailScreen({required this.site, this.id});

  void _openGoogleMaps() async {
    double latitude = site['latitude'] != null ? (site['latitude'] as num).toDouble() : 0.0;
    double longitude = site['longitude'] != null ? (site['longitude'] as num).toDouble() : 0.0;

    String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      print("Could not launch $googleMapsUrl");
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
      appBar: AppBar(title: Text(name),
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
                return Image.asset("assets/placeholder.jpg", width: double.infinity, height: 250, fit: BoxFit.cover);
              },
            )
                : Image.asset("assets/placeholder.jpg", width: double.infinity, height: 250, fit: BoxFit.cover),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                      Text("Lat: $latitude, Long: $longitude", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Icon(Icons.map),
                    label: Text("View on Google Maps"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _openGoogleMaps,
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
