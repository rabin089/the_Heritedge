// lib/screens/heritage_detail_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_heritedge/Common/services/bookmarks_services.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../widgets/comment.section.widget.dart';

class HeritageDetailScreen extends StatefulWidget {
  final Map<String, dynamic> site;

  const HeritageDetailScreen({required this.site, super.key});

  @override
  State<HeritageDetailScreen> createState() => _HeritageDetailScreenState();
}

class _HeritageDetailScreenState extends State<HeritageDetailScreen> {
  bool isBookmarked = false;
  final bookmarkService = BookmarkService();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    final siteId = widget.site["id"];
    if (siteId != null) {
      final bookmarked = await bookmarkService.isBookmarked(siteId);
      setState(() {
        isBookmarked = bookmarked;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    final siteId = widget.site["id"];
    if (siteId != null) {
      if (isBookmarked) {
        await bookmarkService.removeBookmark(siteId);
      } else {
        await bookmarkService.addBookmark(siteId, widget.site);
      }
      setState(() {
        isBookmarked = !isBookmarked;
      });
    }
  }

  void _launchUrlWithFallback(BuildContext context, String url) async {
    try {
      bool launched = await launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) _showFallbackDialog(context, url);
    } catch (_) {
      _showFallbackDialog(context, url);
    }
  }

  void _showFallbackDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Open in Browser?'),
            content: Text('Could not open the app. Open in browser instead?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  if (await canLaunchUrlString(url)) {
                    await launchUrlString(
                      url,
                      mode: LaunchMode.platformDefault,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not open link.')),
                    );
                  }
                },
                child: Text('Open Browser'),
              ),
            ],
          ),
    );
  }

  void _openGoogleMaps() {
    final lat = widget.site["latitude"]?.toString() ?? "0.0";
    final lon = widget.site["longitude"]?.toString() ?? "0.0";
    final url = "https://www.google.com/maps/search/?api=1&query=$lat,$lon";
    _launchUrlWithFallback(context, url);
  }

  void _openGoogleMapsDirections() {
    final lat = widget.site["latitude"]?.toString() ?? "0.0";
    final lon = widget.site["longitude"]?.toString() ?? "0.0";
    final url =
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=driving";
    _launchUrlWithFallback(context, url);
  }

  @override
  Widget build(BuildContext context) {
    print('Site userId: ${widget.site['userId']}');
    String name = widget.site["name"] ?? "No Name";
    String location = widget.site["location"] ?? "Unknown Location";
    String description = widget.site["description"] ?? "No Description";
    String imageUrl = widget.site["imageUrl"] ?? "";
    String latitude = widget.site["latitude"]?.toString() ?? "Unknown";
    String longitude = widget.site["longitude"]?.toString() ?? "Unknown";

    final bool isOwner = user?.uid == widget.site['userId'];

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _toggleBookmark,
          ),
        ],
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
                )
                : Image.asset(
                  "assets/placeholder.jpg",
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
            Padding(
              padding: const EdgeInsets.all(16),
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
                      Expanded(
                        child: Text(location, style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(description, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.map, color: Colors.blue),
                      SizedBox(width: 5),
                      Text("Lat: $latitude, Long: $longitude"),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Icon(Icons.map_outlined),
                    label: Text("View on Google Maps"),
                    onPressed: _openGoogleMaps,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: Icon(Icons.directions),
                    label: Text("Get Directions"),
                    onPressed: _openGoogleMapsDirections,
                  ),
                  SizedBox(height: 20),
                  CommentSection(
                    siteId: widget.site['id'] ?? '',
                    siteOwnerId: widget.site['userId'] ?? '',
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
