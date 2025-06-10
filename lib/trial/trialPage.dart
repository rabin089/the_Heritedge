import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart' as geo;

import '../Common/widgets/filter.section.widget.dart';
 // Your filter dialog widget

class HeritageDemoService {
  final CollectionReference _heritageCollection =
  FirebaseFirestore.instance.collection('heritage_sites');

  Future<List<Map<String, dynamic>>> fetchHeritageSitesFiltered({
    String? region,
    String? category,
    List<String>? tags,
  }) async {
    try {
      Query query = _heritageCollection.where('isPending', isEqualTo: false);

      if (region != null && region != "All") {
        query = query.where('region', isEqualTo: region);
      }
      if (category != null && category != "All") {
        query = query.where('category', isEqualTo: category);
      }
      if (tags != null && tags.isNotEmpty) {
        // Assuming 'tags' is a field which is an array of strings in Firestore
        query = query.where('tags', arrayContainsAny: tags);
      }

      QuerySnapshot snapshot = await query.orderBy('timestamp', descending: true).get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unnamed',
          'location': data['location'] ?? 'Unknown location',
          'region': data['region'] ?? '',
          'category': data['category'] ?? '',
          'tags': data['tags'] ?? [],
        };
      }).toList();
    } catch (e) {
      debugPrint("Error fetching filtered sites: $e");
      return [];
    }
  }
}

class DemoHomeScreen extends StatefulWidget {
  const DemoHomeScreen({super.key});

  @override
  State<DemoHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<DemoHomeScreen> {
  final HeritageDemoService _heritageService = HeritageDemoService();
  List<Map<String, dynamic>> _sites = [];
  bool _loading = false;

  // Current filter selections
  String selectedRegion = "All";
  String selectedCategory = "All";
  List<String> selectedTags = [];

  @override
  void initState() {
    super.initState();
    _fetchSites(); // Initial fetch with no filters
  }

  Future<void> _fetchSites() async {
    setState(() {
      _loading = true;
    });

    final sites = await _heritageService.fetchHeritageSitesFiltered(
      region: selectedRegion,
      category: selectedCategory,
      tags: selectedTags,
    );

    setState(() {
      _sites = sites;
      _loading = false;
    });
  }

  // Future<void> _openFilterDialog() async {
  //   final result = await showDialog<Map<String, dynamic>>(
  //     context: context,
  //     builder: (context) => const FilterSectionWidget(),
  //   );
  //
  //   if (result != null) {
  //     setState(() {
  //       selectedRegion = result['region'] ?? "All";
  //       selectedCategory = result['category'] ?? "All";
  //       selectedTags = List<String>.from(result['tags'] ?? []);
  //     });
  //
  //     await _fetchSites();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Heritage Sites"),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.filter_list),
          //   onPressed: _openFilterDialog,
          // ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sites.isEmpty
          ? const Center(child: Text("No heritage sites found."))
          : ListView.builder(
        itemCount: _sites.length,
        itemBuilder: (context, index) {
          final site = _sites[index];
          return ListTile(
            title: Text(site['name']),
            subtitle: Text(site['location']),
            trailing: Wrap(
              spacing: 6,
              children: [
                if (site['region'] != null && site['region'] != '')
                  Chip(label: Text(site['region'])),
                if (site['category'] != null && site['category'] != '')
                  Chip(label: Text(site['category'])),
              ],
            ),
          );
        },
      ),
    );
  }
}
