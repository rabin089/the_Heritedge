import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_heritedge/Common/utility/distance.calculator.utils.dart';

import '../Screens/heritage_detail_screen.dart';

class HeritageResultCard extends StatelessWidget {
  final DocumentSnapshot doc;
  final double userLat;
  final double userLng;
  final List<DocumentSnapshot> allSites;

  const HeritageResultCard({
    super.key,
    required this.doc,
    required this.userLat,
    required this.userLng,
    required this.allSites,
  });

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final lat = double.parse(data['latitude'].toString());
    final lng = double.parse(data['longitude'].toString());
    final distance = calculateDistance(userLat, userLng, lat, lng);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                return Icon(Icons.landscape, color: Theme.of(context).primaryColor);
              },
            ),
          )
              : Icon(Icons.landscape, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          data['name'] ?? 'Unknown Site',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${distance.toStringAsFixed(2)} km away'),
            if (data['region'] != null && data['region'].toString().isNotEmpty)
              Text('Region: ${data['region']}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HeritageDetailScreen(
                site: {
                  ...data,
                  'id': doc.id,
                },
                allSites: allSites.map((d) => {
                  ...(d.data() as Map<String, dynamic>? ?? {}),
                  'id': d.id,
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
