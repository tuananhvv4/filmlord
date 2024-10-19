import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryFirebaseController {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  final String collectionName = 'history';
  final String childCollection = 'episodes';

  String getCurrentEmail() {
    return FirebaseAuth.instance.currentUser!.email.toString();
  }

  Stream<QuerySnapshot> historyQuery() {
    final querySnapshot = db
        .collection('users')
        .doc(getCurrentEmail())
        .collection('history')
        .orderBy('time', descending: true)
        .limit(10)
        .snapshots();
    return querySnapshot;
  }

  Stream<QuerySnapshot> episodeQuery(String documentID) {
    final querySnapshot = db
        .collection('users')
        .doc(getCurrentEmail())
        .collection('history')
        .doc(documentID)
        .collection(childCollection)
        .orderBy('time', descending: true)
        .limit(1)
        .snapshots();
    return querySnapshot;
  }

  Future<bool> checkDocumentExists(String documentId) async {
    try {
      // Truy cập vào tài liệu dựa trên ID trong Firestore
      DocumentSnapshot documentSnapshot = await db
          .collection('users')
          .doc(getCurrentEmail())
          .collection(collectionName)
          .doc(documentId)
          .get();

      // Trả về true nếu tài liệu tồn tại, ngược lại trả về false
      return documentSnapshot.exists;
    } catch (e) {
      log('Lỗi: $e');
      return false; // Trường hợp lỗi, trả về false
    }
  }

  Future<bool> checkEpisodeExists(
      String documentId, String childDocumentID) async {
    try {
      // Truy cập vào tài liệu dựa trên ID trong Firestore
      DocumentSnapshot documentSnapshot = await db
          .collection('users')
          .doc(getCurrentEmail())
          .collection(collectionName)
          .doc(documentId)
          .collection(childCollection)
          .doc(childDocumentID)
          .get();

      // Trả về true nếu tài liệu tồn tại, ngược lại trả về false
      return documentSnapshot.exists;
    } catch (e) {
      log('Lỗi: $e');
      return false; // Trường hợp lỗi, trả về false
    }
  }

  Future addHistoryMovie(
      String name, String slug, String thumb_url, String poster_url) async {
    bool existDocument = await checkDocumentExists(slug);

    final DocumentReference documentReference = db
        .collection('users')
        .doc(getCurrentEmail())
        .collection('history')
        .doc(slug);
    if (existDocument) {
      documentReference.update({'time': Timestamp.now()});
    } else {
      try {
        documentReference.set({
          'name': name,
          'slug': slug,
          'thumb_url': thumb_url,
          'poster_url': poster_url,
          'time': Timestamp.now()
        });
      } catch (e) {
        log(e.toString());
      }
    }
  }

  Future addEpisode(
      String movieName,
      String slug,
      String thumb_url,
      String poster_url,
      String movie_url,
      String episodeName,
      int index) async {
    addHistoryMovie(movieName, slug, thumb_url, poster_url);

    bool existEpisode = await checkEpisodeExists(slug, episodeName);

    final DocumentReference documentReference = db
        .collection('users')
        .doc(getCurrentEmail())
        .collection('history')
        .doc(slug)
        .collection(childCollection)
        .doc(episodeName);
    if (existEpisode) {
      documentReference.update({'time': Timestamp.now()});
    } else {
      try {
        documentReference.set({
          'episodeName': episodeName,
          'slug': slug,
          'movie_url': movie_url,
          'index': index,
          'currentWatchingTime': 0,
          'time': Timestamp.now()
        });
      } catch (e) {
        log(e.toString());
      }
    }
  }

  Future<void> updateWatchingTime(
      String slug, String episodeName, int currentWatchingTime) async {
    final DocumentReference documentReference = db
        .collection('users')
        .doc(getCurrentEmail())
        .collection('history')
        .doc(slug)
        .collection(childCollection)
        .doc(episodeName);
    documentReference.update({
      'currentWatchingTime': currentWatchingTime,
    });
  }

  Future<void> removeHistoryMovie(String docID) async {
    try {
      // Kiểm tra xem currentUserEmail có null không trước khi truy cập thuộc tính email
      if (getCurrentEmail().isNotEmpty) {
        final DocumentReference documentReference = db
            .collection('users')
            .doc(getCurrentEmail())
            .collection(collectionName)
            .doc(docID);
        final CollectionReference collectionReference = db
            .collection('users')
            .doc(getCurrentEmail())
            .collection(collectionName)
            .doc(docID)
            .collection('episodes');

        await documentReference.delete();
      } else {
        log('currentUserEmail is null. Cannot delete movie.');
      }
    } catch (e) {
      log('Failed to delete movie: $e');
    }
  }

  Future<void> deleteDocumentWithSubCollections(String docID) async {
    try {
      // Lấy tài liệu cần xóa
      final documentRef = db
          .collection('users')
          .doc(getCurrentEmail())
          .collection(collectionName)
          .doc(docID);

      // Xóa các tài liệu trong subcollections (nếu biết tên subcollections)
      final subcollections = ['episodes']; // Tên subcollections

      for (final subcollectionName in subcollections) {
        final subcollectionRef = documentRef.collection(subcollectionName);
        final subcollectionDocs = await subcollectionRef.get();
        for (final doc in subcollectionDocs.docs) {
          await doc.reference.delete();
        }
      }
      // Xóa tài liệu gốc
      await documentRef.delete();

      print('Tài liệu và subcollections đã được xóa thành công!');
    } catch (e) {
      print('Lỗi khi xóa tài liệu: $e');
    }
  }

  Future addHistoryActivity(String name, String slug, String action) async {
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
