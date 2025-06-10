import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

import 'edit.profile..page.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? username;
  String? profileImageUrl;
  List<Map<String, dynamic>> contributions = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('roles_for_users').doc(user.uid).get();
    final userData = userDoc.data();
    if (userData != null) {
      print("User details: $userData");
      username = userData['username'];
      profileImageUrl = userData['profileImageUrl'];
    }

    final siteQuery = await _firestore
        .collection('heritage_sites')
        .where('userId', isEqualTo: user.uid)
        .get();

    contributions = siteQuery.docs.map((doc) => doc.data()).toList();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _updateProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final File file = File(picked.path);

      final ref = _storage.ref().child('profile_images').child('${_auth.currentUser!.uid}.jpg');
      await ref.putFile(file);
      final uploadedUrl = await ref.getDownloadURL();

      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'profileImageUrl': uploadedUrl,
      });

      setState(() {
        profileImageUrl = uploadedUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated")),
      );
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
    if (result == true) {
      _fetchUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Profile")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Profile"),
        backgroundColor: const Color(0xFF795548),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              // onTap: profileImageUrl == null ? _updateProfileImage : null,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl!)
                    : null,
                child: profileImageUrl == null
                    ? const Icon(Icons.camera_alt, size: 30, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            Text(username ?? "Name not set", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Your Contributions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: contributions.isEmpty
                  ? const Center(child: Text("No contributions yet."))
                  : ListView.builder(
                itemCount: contributions.length,
                itemBuilder: (context, index) {
                  final site = contributions[index];
                  return Card(
                    child: ListTile(
                      title: Text(site['name'] ?? 'Unnamed Site'),
                      subtitle: Text(site['region'] ?? 'Unknown Region'),
                      leading: site['imageUrl'] != null
                          ? Image.network(site['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                          : const Icon(Icons.image),
                      trailing: Text(
                        site['isPending'] == true ? 'Pending' : 'Approved',
                        style: TextStyle(
                          color: site['isPending'] == true ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
