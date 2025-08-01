import 'package:flutter/material.dart';
import '../services/bookmarks_services.dart';
import 'heritage_detail_screen.dart';

class BookmarkListScreen extends StatelessWidget {
  final bookmarkService = BookmarkService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Edge Collection "),
        backgroundColor: Colors.brown,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: bookmarkService.getBookmarks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Something went wrong."));
          }

          final bookmarks = snapshot.data ?? [];

          if (bookmarks.isEmpty) {
            return Center(child: Text("No bookmarks yet."));
          }

          return ListView.builder(
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final site = bookmarks[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: site["imageUrl"] != null && site["imageUrl"].isNotEmpty
                      ? Image.network(site["imageUrl"], width: 60, height: 60, fit: BoxFit.cover)
                      : Image.asset("assets/placeholder.jpg", width: 60, height: 60),
                  title: Text(site["name"] ?? "No Name"),
                  subtitle: Text(site["location"] ?? "No Location"),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HeritageDetailScreen(site: site, allSites: bookmarks),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
