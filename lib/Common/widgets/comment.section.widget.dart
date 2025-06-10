import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentSection extends StatefulWidget {
  final String siteId;
  final String siteOwnerId;

  const CommentSection({
    required this.siteId,
    required this.siteOwnerId,
    super.key,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0.0;
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _submitComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty || user == null) return;
    if (user!.uid == widget.siteOwnerId) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('roles_for_users')
        .doc(user!.uid)
        .get();
    final username = userDoc.data()?['username'] ?? 'Anonymous';

    await FirebaseFirestore.instance
        .collection('heritage_sites')
        .doc(widget.siteId)
        .collection('comments')
        .add({
      'userId': user!.uid,
      'username': username,
      'comment': commentText,
      'rating': _rating,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _commentController.clear();
    setState(() {
      _rating = 0.0;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Comment submitted!')));
  }

  @override
  Widget build(BuildContext context) {
    final bool isOwner = user?.uid == widget.siteOwnerId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isOwner)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Rate this Site:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.blueGrey,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1.0;
                      });
                    },
                  );
                }),
              ),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(labelText: 'Leave a comment'),
                maxLines: null,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _submitComment,
                child: Text("Submit"),
              ),
              SizedBox(height: 20),
            ],
          ),
        Text(
          "Comments",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('heritage_sites')
              .doc(widget.siteId)
              .collection('comments')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());

            final comments = snapshot.data?.docs ?? [];
            if (comments.isEmpty) return Text("No comments yet.");

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final data =
                comments[index].data() as Map<String, dynamic>;
                final timestamp = data['timestamp'] as Timestamp?;
                final formattedDate = timestamp != null
                    ? DateFormat.yMMMMd().format(timestamp.toDate())
                    : null;

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      data['username']?.substring(0, 1).toUpperCase() ?? "?",
                    ),
                  ),
                  title: Text(data['username'] ?? 'User'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['comment'] ?? ''),
                      SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < (data['rating'] ?? 0)
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.blueGrey,
                            size: 16,
                          );
                        }),
                      ),
                      if (formattedDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Posted on: $formattedDate',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
