import 'package:flutter/material.dart';

class UserManagementCard extends StatelessWidget {
  const UserManagementCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace with real data source
    final users = [
      {'name': 'Rabin Dulal', 'role': 'Admin'},
      {'name': 'Subash Shrestha', 'role': 'Editor'},
      {'name': 'Guest User', 'role': 'Viewer'},
    ];

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            leading: Icon(Icons.people),
            title: Text('User Management'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, idx) {
                final user = users[idx];
                return ListTile(
                  title: Text(user['name']!),
                  subtitle: Text(user['role']!),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      /* Implement edit logic */
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
