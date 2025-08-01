import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_heritedge/Common/services/bookmarks_services.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../User/ui/screens/heritage.map.screen.dart';
import '../widgets/comment.section.widget.dart';

class HeritageDetailScreen extends StatefulWidget {
  final Map<String, dynamic> site;
  final List<Map<String, dynamic>> allSites; // Pass all sites here for map screen

  const HeritageDetailScreen({
    required this.site,
    required this.allSites, // Add this to constructor
    super.key,
  });

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

  void _openHeritageMapScreen() {
    final lat = widget.site["latitude"] ?? 0.0;
    final lon = widget.site["longitude"] ?? 0.0;
    final siteName = widget.site["name"] ?? "Unknown Site";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HeritageMapScreen(
          siteName: siteName,
          latitude: lat is double ? lat : double.tryParse(lat.toString()) ?? 0.0,
          longitude: lon is double ? lon : double.tryParse(lon.toString()) ?? 0.0,
          allSites: widget.allSites,
        ),
      ),
    );
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

  void _openGoogleMapsDirections() {
    final lat = widget.site["latitude"]?.toString() ?? "0.0";
    final lon = widget.site["longitude"]?.toString() ?? "0.0";
    final url =
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=driving";
    _launchUrlWithFallback(context, url);
  }
  @override
  Widget build(BuildContext context) {
    String name = widget.site["name"] ?? "No Name";
    String location = widget.site["location"] ?? "Unknown Location";
    String description = widget.site["description"] ?? "No Description";
    String imageUrl = widget.site["imageUrl"] ?? "";
    String latitude = widget.site["latitude"]?.toString() ?? "Unknown";
    String longitude = widget.site["longitude"]?.toString() ?? "Unknown";

    final List<dynamic> secondaryImages = widget.site['secondaryImages'] ?? [];

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Primary image
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
        
              // Secondary Images horizontal list
              if (secondaryImages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Additional Images",
                        style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: secondaryImages.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final image = secondaryImages[index].toString();
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => Dialog(
                                    insetPadding: const EdgeInsets.all(16),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: InteractiveViewer(
                                        child: Image.network(
                                          image,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  image,
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      width: 80,
                                      height: 80,
                                      child: const Icon(Icons.broken_image),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        
              // Remaining content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(location, style: const TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(description, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.map, color: Colors.blue),
                        const SizedBox(width: 5),
                        Text("Lat: $latitude, Long: $longitude"),
                      ],
                    ),
                    const SizedBox(height: 20),
        
                    // View on Google Maps button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.map_outlined),
                      label: const Text("View on Google Maps"),
                      onPressed: _openHeritageMapScreen,
                    ),
        
                    const SizedBox(height: 10),
        
                    // Get Directions button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.directions),
                      label: const Text("Get Directions"),
                      onPressed: _openGoogleMapsDirections,
                    ),
        
                    const SizedBox(height: 20),
        
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
      ),
    );
  }
}
