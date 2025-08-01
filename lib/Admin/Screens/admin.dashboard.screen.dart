import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_heritedge/Admin/widgets/adminAppbar.dart';

import '../widgets/adminDrawer.dart';
import 'edit.heritage.site.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currentUsers = FirebaseAuth.instance.currentUser;
  String? uid;
  String? adminName;
  String? currentUserRole;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final tabs = const [
    Tab(text: 'Users'),
    Tab(text: 'Heritage Sites'),
    Tab(text: 'Contributions'),
    Tab(text: 'Reviews'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    uid = currentUsers?.uid;
    if (currentUsers != null) {
      FirebaseFirestore.instance
          .collection('roles_for_users')
          .doc(currentUsers!.uid)
          .get()
          .then((doc) {
        if (doc.exists) {
          setState(() {
            adminName = doc.data()?['username'] ?? 'Admin';
            currentUserRole = doc.data()?['role'] ?? 'user';
          });
        } else {
          setState(() {
            adminName = 'Admin';
            currentUserRole = 'user';
          });
        }
      });
    } else {
      adminName = 'Admin';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void approveContribution(String docId) {
    FirebaseFirestore.instance.collection('heritage_sites').doc(docId).update({
      'isPending': false,
    });
  }

  void deleteContribution(String docId) {
    FirebaseFirestore.instance.collection('heritage_sites').doc(docId).delete();
  }

  void approveHeritageSite(String docId) {
    FirebaseFirestore.instance.collection('heritage_sites').doc(docId).update({
      'isPending': true,
    });
  }

  void deleteHeritageSite(String docId) {
    FirebaseFirestore.instance.collection('heritage_sites').doc(docId).delete();
  }
  void deleteUser(String userId) async {
    await FirebaseFirestore.instance
        .collection('roles_for_users')
        .doc(userId)
        .delete();
  }


  Future<bool> _showDeleteConfirmationDialog(BuildContext context, String itemType) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $itemType'),
        content: Text('Are you sure you want to delete this $itemType?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AdminCustomAppBar(
        onMenuTap: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: AdminDrawer(),
      body: Column(
        children: [
          Container(
            color: Colors.brown[50],
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.brown,
              indicatorColor: Colors.brown,
              unselectedLabelColor: Colors.grey,
              tabs: tabs,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              adminName != null ? 'Welcome, $adminName' : '',
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Users Tab
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('roles_for_users')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No users found."));
                    }

                    final users = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final doc = users[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final userId = doc.id;
                        final isCurrentUser = userId == uid;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.brown[100],
                            child: Text(
                              (data['username'] != null && data['username'].isNotEmpty)
                                  ? data['username'][0]
                                  : '?',
                              style: const TextStyle(color: Colors.brown),
                            ),
                          ),
                          title: Text(
                            data['username'] ?? 'Unnamed User',
                            style: TextStyle(
                              fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                              color: isCurrentUser ? Colors.brown : null,
                            ),
                          ),
                          subtitle: Text(data['email'] ?? 'No email'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(data['role'] ?? 'No role'),
                              const SizedBox(width: 6),
                              if (currentUserRole == 'superadmin' && !isCurrentUser) ...[
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showEditUserRoleDialog(userId, data['role']),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final shouldDelete = await _showDeleteConfirmationDialog(context, "user");
                                    if (shouldDelete) {
                                      deleteUser(userId);
                                    }
                                  },
                                ),
                              ],
                              if (isCurrentUser)
                                const Icon(Icons.star, color: Colors.orange, size: 18),
                            ],
                          ),

                        );
                      },
                    );
                  },
                ),

                // Heritage Sites Tab (with delete confirmation)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('heritage_sites')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No heritage sites found."));
                    }
                    final sites = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: sites.length,
                      itemBuilder: (context, index) {
                        final doc = sites[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final isApproved = data['isPending'] ?? true;
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(data['name'] ?? 'Unnamed Site'),
                            subtitle: Text(data['location'] ?? 'Unknown location'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditHeritageSitePage(
                                          docId: doc.id,
                                          data: data,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final shouldDelete = await _showDeleteConfirmationDialog(context, "heritage site");
                                    if (shouldDelete) {
                                      deleteHeritageSite(doc.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                // Contributions Tab (with delete confirmation)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('heritage_sites')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No contributions found."));
                    }
                    final contributions = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: contributions.length,
                      itemBuilder: (context, index) {
                        final doc = contributions[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final isPending = data['isPending'] ?? true;
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.brown[100],
                              child: Text(
                                data['name'] != null && data['name'].isNotEmpty
                                    ? data['name'][0]
                                    : '?',
                                style: const TextStyle(color: Colors.brown),
                              ),
                            ),
                            title: Text(data['name'] ?? 'Unnamed Contribution'),
                            subtitle: Text(data['location'] ?? 'Unknown location'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isPending)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    onPressed: () => approveContribution(doc.id),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final shouldDelete = await _showDeleteConfirmationDialog(context, "contribution");
                                    if (shouldDelete) {
                                      deleteContribution(doc.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                // Reviews Tab - with Delete Option for Comments
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('heritage_sites').snapshots(),
                  builder: (context, siteSnapshot) {
                    if (siteSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!siteSnapshot.hasData || siteSnapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No heritage sites found."));
                    }
                    final sites = siteSnapshot.data!.docs;
                    return ListView.builder(
                      itemCount: sites.length,
                      itemBuilder: (context, siteIndex) {
                        final siteDoc = sites[siteIndex];
                        final siteData = siteDoc.data() as Map<String, dynamic>;
                        final siteName = siteData['name'] ?? 'Unnamed Site';

                        return ExpansionTile(
                          title: Text(siteName),
                          children: [
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('heritage_sites')
                                  .doc(siteDoc.id)
                                  .collection('comments')
                                  .snapshots(),
                              builder: (context, commentSnapshot) {
                                if (commentSnapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (!commentSnapshot.hasData || commentSnapshot.data!.docs.isEmpty) {
                                  return const ListTile(title: Text("No comments."));
                                }
                                final comments = commentSnapshot.data!.docs;
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: comments.length,
                                  itemBuilder: (context, commentIndex) {
                                    final commentDoc = comments[commentIndex];
                                    final commentData = commentDoc.data() as Map<String, dynamic>;
                                    final commentorId = commentData['commentorId'] ?? 'Unknown';
                                    final comment = commentData['comment'] ?? '';
                                    final rating = commentData['rating']?.toString() ?? 'No rating';

                                    return ListTile(
                                      leading: const Icon(Icons.comment, color: Colors.brown),
                                      title: Text(comment),
                                      subtitle: Text('Rating: $rating\nBy: $commentorId'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          final shouldDelete = await _showDeleteConfirmationDialog(context, "comment");
                                          if (shouldDelete) {
                                            await FirebaseFirestore.instance
                                                .collection('heritage_sites')
                                                .doc(siteDoc.id)
                                                .collection('comments')
                                                .doc(commentDoc.id)
                                                .delete();
                                          }
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditUserRoleDialog(String userId, String currentRole) {
    String selectedRole = currentRole;

    List<String> allowedRoles = currentUserRole == 'superadmin'
        ? [ 'admin', 'user']
        : [ 'user'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit User Role'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                value: allowedRoles.contains(selectedRole) ? selectedRole : 'user',
                items: allowedRoles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role[0].toUpperCase() + role.substring(1)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Select Role'),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedRole != currentRole) {
                  await FirebaseFirestore.instance
                      .collection('roles_for_users')
                      .doc(userId)
                      .update({'role': selectedRole});

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User role updated successfully')),
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
