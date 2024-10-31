import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentFirebaseController {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static String getCurrentEmail() {
    return FirebaseAuth.instance.currentUser!.email.toString();
  }

  // Truy vấn dữ liệu
  static Stream<QuerySnapshot> commentQuery(String slug) {
    final querySnapshot = db
        .collection('movies')
        .doc(slug)
        .collection('comments')
        .orderBy('time', descending: true)
        .limit(50)
        .snapshots();
    return querySnapshot;
  }

  static Future<bool> checkDocumentExists(String documentID) async {
    try {
      // Truy cập vào tài liệu dựa trên ID trong Firestore
      DocumentSnapshot documentSnapshot =
          await db.collection('movies').doc(documentID).get();

      // Trả về true nếu tài liệu tồn tại, ngược lại trả về false
      return documentSnapshot.exists;
    } catch (e) {
      log('Lỗi: $e');
      return false; // Trường hợp lỗi, trả về false
    }
  }

  static Future addMovie(
      String name, String slug, String thumb_url, String poster_url) async {
    bool existDocument = await checkDocumentExists(slug);
    if (!existDocument) {
      try {
        final DocumentReference documentReference =
            db.collection('movies').doc(slug);
        documentReference.set({
          'name': name,
          'slug': slug,
          'thumb_url': thumb_url,
          'poster_url': poster_url,
        });
      } catch (e) {
        log(e.toString());
      }
    }
  }

  static Future addComment(String commentContent, String name, String slug,
      String thumb_url, String poster_url) async {
    await addMovie(name, slug, thumb_url, poster_url);

    final DocumentReference documentReference =
        db.collection('movies').doc(slug).collection('comments').doc();
    try {
      documentReference.set({
        'content': commentContent,
        'user': getCurrentEmail(),
        'time': Timestamp.now()
      });
    } catch (e) {
      log('Lỗi khi thêmm');
    }
  }

  static Future addHistoryActivity(
      String name, String slug, String action) async {
    String actionContent = '';
    if (action == 'comment') {
      actionContent = 'Đã thêm 1 bình luận!';
    }
    if (action == 'rating') {
      actionContent = 'Đã thêm 1 đánh giá!';
    }
    final DocumentReference documentReference = db
        .collection('users')
        .doc(getCurrentEmail())
        .collection('activity')
        .doc();
    try {
      documentReference.set({
        'movie': name,
        'slug': slug,
        'action': action,
        'content': actionContent,
        'time': Timestamp.now()
      });
    } catch (e) {
      log(e.toString());
    }
  }
}
