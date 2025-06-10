import 'package:flutter/material.dart';
import 'package:the_heritedge/Common/Screens/heritage_detail_screen.dart';

class HeritageSiteCard extends StatelessWidget {
  final Map<String, dynamic> site;

  const HeritageSiteCard({Key? key, required this.site}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = site['imageUrl'] ?? site['imageurl'] ?? '';
    final hasValidImage = imageUrl.isNotEmpty && imageUrl.startsWith('http');

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: SizedBox(
          width: 180, // Fix width for horizontal list
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child:
                    hasValidImage
                        ? Image.network(
                          imageUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('Image load error: $error');
                            return _placeholderImage();
                          },
                        )
                        : _placeholderImage(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      site['name'] ?? "Unnamed",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      site['location'] ?? "Location not specified",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (site['distance'] != null)
                      Text(
                        '${(site['distance'] as double).toStringAsFixed(1)} km away',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.brown[600],
                        ),
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

  Widget _placeholderImage() {
    return Container(
      height: 120,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
      ),
    );
  }
}
