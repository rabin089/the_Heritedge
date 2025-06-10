import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/imgbb.services.dart'; // Make sure this file contains ImgBBService

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _username;
  String? _existingImageUrl;
  File? _profileImage;

  bool isLoading = true;
  final ImgBBService _imgBBService = ImgBBService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await _firestore
        .collection('roles_for_users')
        .doc(_auth.currentUser!.uid)
        .get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _username = data['username'];
        _existingImageUrl = data['profileImageUrl'];
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  // ✅ Upload to ImgBB instead of Firebase Storage
  Future<String?> _uploadImage(File image) async {
    return await _imgBBService.uploadImage(image);
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String? imageUrl = _existingImageUrl;

      if (_profileImage != null) {
        imageUrl = await _uploadImage(_profileImage!);
        if (imageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Image upload failed")),
          );
          return;
        }
      }

      await _firestore
          .collection('roles_for_users')
          .doc(_auth.currentUser!.uid)
          .update({
        'username': _username,
        'profileImageUrl': imageUrl,
      });

      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF795548),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Replace the existing GestureDetector with this code
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : (_existingImageUrl != null
                          ? NetworkImage(_existingImageUrl!)
                          : null) as ImageProvider<Object>?,
                      child: _profileImage == null && _existingImageUrl == null
                          ? const Icon(Icons.camera_alt, size: 50)
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 16),
              TextFormField(
                initialValue: _username,
                decoration: const InputDecoration(labelText: 'Username'),
                onSaved: (value) => _username = value,
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a username' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
