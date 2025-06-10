import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:the_heritedge/Common/Screens/heritage_detail_screen.dart';
import '../services/filter_heritage.service.dart';

class PopularSectionWidget extends StatefulWidget {
  final Position userPosition;

  const PopularSectionWidget({Key? key, required this.userPosition})
      : super(key: key);

  @override
  State<PopularSectionWidget> createState() => _PopularSectionWidgetState();
}

class _PopularSectionWidgetState extends State<PopularSectionWidget> {
  List<Map<String, dynamic>> popularSites = [];

  @override
  void initState() {
    super.initState();
    fetchPopularSites();
  }

  Future<void> fetchPopularSites() async {
    final firestore = FirebaseFirestore.instance;

    QuerySnapshot siteSnapshot =
    await firestore.collection('heritage_sites').get();

    List<Map<String, dynamic>> siteList = [];

    for (var siteDoc in siteSnapshot.docs) {
      String siteId = siteDoc.id;
      String name = siteDoc['name'];
      String imageUrl = siteDoc['imageUrl'];

      double latitude = double.parse(siteDoc['latitude'].toString());
      double longitude = double.parse(siteDoc['longitude'].toString());

      // Calculate distance using your Haversine function
      double distanceInKm = calculateDistance(
        widget.userPosition.latitude,
        widget.userPosition.longitude,
        latitude,
        longitude,
      );

      // Fetch comments and average rating
      QuerySnapshot commentSnapshot = await firestore
          .collection('heritage_sites')
          .doc(siteId)
          .collection('comments')
          .get();

      double averageRating = 0;
      if (commentSnapshot.docs.isNotEmpty) {
        double totalRating = 0;
        for (var commentDoc in commentSnapshot.docs) {
          totalRating += commentDoc['rating'];
        }
        averageRating = totalRating / commentSnapshot.docs.length;
      }

      siteList.add({
        'id': siteId,
        'name': name,
        'imageUrl': imageUrl,
        'averageRating': averageRating,
        'distance': distanceInKm,
        'userId': (siteDoc.data() as Map<String, dynamic>?)?.containsKey('userId') == true ? siteDoc['userId'] : null,
      });
    }

    // Sort by rating descending
    siteList.sort((a, b) => b['averageRating'].compareTo(a['averageRating']));

    setState(() {
      popularSites = siteList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: popularSites.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: popularSites.length,
        itemBuilder: (context, index) {
          final site = popularSites[index];
          return PopularSiteCard(site: site);
        },
      ),
    );
  }
}

class PopularSiteCard extends StatelessWidget {
  final Map<String, dynamic> site;

  const PopularSiteCard({Key? key, required this.site}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate and pass full site map including userId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HeritageDetailScreen(site: site),
          ),
        );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                site['imageUrl'],
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                site['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            site['averageRating'] > 0
                ? Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  site['averageRating'].toStringAsFixed(1),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            )
                : const Text(
              'No ratings yet',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 18),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${site['distance'].toStringAsFixed(2)} km away',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
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
