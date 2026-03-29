import 'package:flutter/material.dart';
import 'package:the_heritedge/Common/Screens/heritage_detail_screen.dart';
import 'package:the_heritedge/Common/widgets/app_drawer.dart';
import 'package:the_heritedge/Common/widgets/custom_app_bar.dart';
import 'package:the_heritedge/User/ui/repository/api_for_homepage.dart';
import 'package:the_heritedge/User/login_sign_up/repository/auth_service.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final HeritageService _heritageService = HeritageService();

  late Future<List<Map<String, dynamic>>> _heritageSitesFuture;
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    _heritageSitesFuture = _heritageService.fetchHeritageSites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onMenuTap:() {
          _scaffoldKey.currentState?.openDrawer(); // Open drawer when menu is pressed
        },
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Explore Nepal's Cultural Heritage",
              style: TextStyle(
              color: Colors.black45,
              fontSize: 20,
              fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
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
        ],
      ),
    );
  }
}