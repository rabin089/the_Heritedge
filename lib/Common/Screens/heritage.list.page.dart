import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:the_heritedge/Common/widgets/custom_app_bar.dart';
import '../../User/ui/repository/api_for_homepage.dart';
import '../utility/distance.calculator.utils.dart';
import 'heritage_detail_screen.dart';

class HeritageListPage extends StatefulWidget {
  HeritageListPage({super.key});

  @override
  State<HeritageListPage> createState() => _HeritageListPageState();
}

class _HeritageListPageState extends State<HeritageListPage> {
  final HeritageService _heritageService = HeritageService();
  late Future<List<Map<String, dynamic>>> _heritageSitesFuture;
  Position? _currentPosition;


  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _heritageSitesFuture = _heritageService.fetchHeritageSites();
  }
  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("Herit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text("Edge", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
          ],
        ),
        backgroundColor: Colors.brown,
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _heritageSitesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No heritage sites found."));
            }

            var sites = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: sites.length,
                itemBuilder: (context, index) {
                  var site = sites[index];
                  String? imageUrl = site['imageUrl'] ?? site['imageurl'];
                  bool hasValidImage = imageUrl != null &&
                      imageUrl.isNotEmpty &&
                      (imageUrl.startsWith('http') || imageUrl.startsWith('https'));

                  return GestureDetector(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              color: Colors.grey[200],
                            ),
                            child: hasValidImage
                                ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                imageUrl!,
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
                                  debugPrint('Image load error: $error for URL: $imageUrl');
                                  return _buildErrorWidget();
                                },
                              ),
                            )
                                : _buildErrorWidget(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  site['name'] ?? 'Unnamed Site',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  site['location'] ?? 'Location not specified',
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                if (_currentPosition != null &&
                                    site['latitude'] != null &&
                                    site['longitude'] != null)
                                  Text(
                                    '${calculateDistance(
                                      _currentPosition!.latitude,
                                      _currentPosition!.longitude,
                                      double.tryParse(site['latitude'].toString()) ?? 0.0,
                                      double.tryParse(site['longitude'].toString()) ?? 0.0,
                                    ).toStringAsFixed(2)} km away',
                                    style: TextStyle(fontSize: 12, color: Colors.brown[600]),
                                  )
                                else
                                  const Text(
                                    'Distance: --',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_not_supported, size: 40),
          const SizedBox(height: 8),
          Text(
            'Image not available',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}