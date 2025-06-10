import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookmarkService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser!.uid;

  Future<void> addBookmark(String siteId, Map<String, dynamic> siteData) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(siteId)
        .set(siteData);
  }


  Future<bool> isBookmarked(String siteId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(siteId)
        .get();
    return doc.exists;
  }

  Future<void> removeBookmark(String siteId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(siteId)
        .delete();
  }

  Stream<List<Map<String, dynamic>>> getBookmarks() {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

}
