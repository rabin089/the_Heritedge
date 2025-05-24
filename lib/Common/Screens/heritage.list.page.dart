import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the_heritedge/Common/widgets/custom_app_bar.dart';

import '../../User/ui/repository/api_for_homepage.dart';
import 'heritage_detail_screen.dart';

class HeritageListPage extends StatefulWidget {
  HeritageListPage({super.key});

  @override
  State<HeritageListPage> createState() => _HeritageListPageState();
}

class _HeritageListPageState extends State<HeritageListPage> {
  final HeritageService _heritageService = HeritageService();

  late Future<List<Map<String, dynamic>>> _heritageSitesFuture;

  @override
  void initState() {
    super.initState();
    _heritageSitesFuture = _heritageService.fetchHeritageSites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("Herit",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
            Text("Edge",style: TextStyle(color:Colors.black,fontWeight:FontWeight.bold ),)
          ],
        ),
        backgroundColor: Colors.brown,
      ),
      body: SafeArea(
        child:FutureBuilder(
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
                  crossAxisCount: 2, // 2 columns
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8, // Adjust based on your design
                ),
                itemCount: sites.length,
                itemBuilder: (context, index) {
                  var site = sites[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HeritageDetailScreen( site: site),
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
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              site['imageUrl'],
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported, size: 50),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  site['name'],
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  site['location'],
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
}
