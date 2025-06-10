import 'package:flutter/material.dart';
import 'package:googleapis/datamigration/v1.dart';
import 'package:the_heritedge/Common/services/geolocator.service.dart';
import 'package:the_heritedge/Common/sizedBox/sized.box.widget.dart';
import 'package:the_heritedge/Common/widgets/app_drawer.dart';
import 'package:the_heritedge/Common/widgets/custom_app_bar.dart';
import 'package:the_heritedge/Common/widgets/suggestion.header.widget.dart';
import 'package:the_heritedge/User/ui/repository/api_for_homepage.dart';
import 'package:the_heritedge/User/login_sign_up/repository/auth_service.dart';
import 'package:geolocator/geolocator.dart' as geo;
import '../../Admin/widgets/heritageSite.card.dart';
import '../utility/distance.calculator.utils.dart';
import '../widgets/filter.section.widget.dart';
import '../widgets/location_based.suggestion.widget.dart';
import '../widgets/popular.section.widget.dart';
import '../widgets/search._bar.widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final HeritageService _heritageService = HeritageService();

  late Future<List<dynamic>> _initFuture;
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _allSites = [];
  List<Map<String, dynamic>> _filteredSites = [];
  geo.Position? _userPosition;
  final double maxDistanceKm = 50;

  @override
  void initState() {
    super.initState();
    _initFuture = Future.wait([
      _heritageService.fetchHeritageSites(),
      LocationService().getCurrentPosition()
    ]);
  }

  List<Map<String, dynamic>> _filterSites(
      String query,
      List<Map<String, dynamic>> sites,
      geo.Position? userPos,
      ) {
    if (userPos == null) return [];

    final lowerQuery = query.toLowerCase();

    return sites.where((site) {
      final name = (site['name'] ?? '').toString().toLowerCase();
      final lat = site['latitude'] as double;
      final lon = site['longitude'] as double;

      final distance = calculateDistance(
        userPos.latitude,
        userPos.longitude,
        lat,
        lon,
      );

      final matchesQuery = name.contains(lowerQuery);
      final withinDistance = distance <= maxDistanceKm;

      return matchesQuery && withinDistance;
    }).toList();
  }

  void _onSearchChanged(String query) {
    if (_userPosition == null) return;

    final filtered = _filterSites(query, _allSites, _userPosition);

    setState(() {
      _filteredSites = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        onMenuTap: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        userLocationFuture: LocationService().getCurrentPosition(),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder<List<dynamic>>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Could not load suggested sites."));
          }

          final sites = snapshot.data![0] as List<Map<String, dynamic>>;
          final userPosition = snapshot.data![1] as geo.Position;

          // Assign values only once
          if (_allSites.isEmpty) {
            _allSites = sites;
            _userPosition = userPosition;
            _filteredSites = sites;
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            children: [
              SuggestedHeritageWidget(
                sites: _allSites,
                userPosition: userPosition,
              ),
              sboxH10,
              SuggestionHeaderWidget(title: "Suggested For You"),

              FilterSectionWidget(
                onApply: ({
                  required String region,
                  required String category,
                  required List<String> tags,
                }) {
                  final results = _filterSitesWithAll(
                    sites: _allSites,
                    query: _controller.text,
                    userPos: _userPosition,
                    region: region == "All" ? "" : region,
                    category: category == "All" ? "" : category,
                    tags: tags,
                  );

                  setState(() {
                    _filteredSites = results;
                  });
                },
              ),

              // ✅ Show filtered sites
              if (_filteredSites.isNotEmpty) ...[
                SizedBox(
                  height: 210, // Adjust height based on your card's content
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filteredSites.length,
                    itemBuilder: (context, index) {
                      final site = _filteredSites[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5, // Half of scaffold width
                          child: HeritageSiteCard(site: site),
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                const SizedBox(height: 16),
                SuggestionHeaderWidget(title: "No matching results"),
              ],

              const SizedBox(height: 20),
              SuggestionHeaderWidget(title: "Most popular Heritage"),
              PopularSectionWidget(userPosition: _userPosition!),
            ],
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _filterSitesWithAll({
    required List<Map<String, dynamic>> sites,
    required String query,
    required geo.Position? userPos,
    required String region,
    required String category,
    required List<String> tags,
  }) {
    if (userPos == null) return [];

    final lowerQuery = query.toLowerCase();

    final filtered = sites.where((site) {
      final name = (site['name'] ?? '').toString().toLowerCase();
      final siteRegion = (site['region'] ?? '').toString().toLowerCase();
      final siteCategory = (site['category'] ?? '').toString().toLowerCase();
      final siteTags = (site['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString().toLowerCase())
          .toList();

      final lat = site['latitude'] as double;
      final lon = site['longitude'] as double;
      final distance = calculateDistance(
        userPos.latitude,
        userPos.longitude,
        lat,
        lon,
      );

      // ✅ Attach distance for sorting and display
      site['distance'] = distance;

      final matchesQuery = name.contains(lowerQuery);
      final matchesRegion = region.isEmpty || siteRegion == region.toLowerCase();
      final matchesCategory = category.isEmpty || siteCategory == category.toLowerCase();
      final matchesTags = tags.isEmpty || tags.every((tag) => siteTags.contains(tag.toLowerCase()));
      final withinDistance = distance <= maxDistanceKm;

      return matchesQuery && matchesRegion && matchesCategory && matchesTags && withinDistance;
    }).toList();

    // ✅ Sort by nearest
    filtered.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    return filtered;
  }



}
