import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  void approveContribution(String docId) {
    FirebaseFirestore.instance
        .collection('contributions')
        .doc(docId)
        .update({'isPending': false});
  }

  void deleteContribution(String docId) {
    FirebaseFirestore.instance.collection('contributions').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.brown,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('heritage_sites').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No contributions yet."));
          }

          final contributions = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: contributions.length,
            itemBuilder: (context, index) {
              final doc = contributions[index];
              final data = doc.data() as Map<String, dynamic>;
              final bool isPending = data['isPending'] ?? true;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.brown[100],
                    child: Text(data['name']?[0] ?? '?', style: const TextStyle(color: Colors.brown)),
                  ),
                  title: Text(data['name'] ?? 'Unnamed'),
                  subtitle: Text(data['location'] ?? 'Unknown location'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPending)
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () => approveContribution(doc.id),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteContribution(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
