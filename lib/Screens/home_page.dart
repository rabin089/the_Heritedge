import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_heritedge/Screens/login_page.dart';
import 'package:the_heritedge/Services/auth_service.dart';
import 'package:your_project/screens/login_screen.dart';
import 'package:your_project/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HeritEdge"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authService.signout();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => LoginScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Explore Nepal's Cultural Heritage",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('heritage_sites').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No heritage sites found."));
                }

                var sites = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: sites.length,
                  itemBuilder: (context, index) {
                    var site = sites[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: Image.network(site['imageUrl'], width: 50, height: 50, fit: BoxFit.cover),
                        title: Text(site['name']),
                        subtitle: Text(site['location']),
                        onTap: () {
                          // Navigate to details page (to be implemented)
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
