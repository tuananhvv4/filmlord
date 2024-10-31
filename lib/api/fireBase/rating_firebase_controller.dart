import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class RatingFirebaseController {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static String getCurrentEmail() {
    return FirebaseAuth.instance.currentUser!.email.toString();
  }

  // Truy vấn dữ liệu
  static Stream<QuerySnapshot> ratingQuery(String slug) {
    final querySnapshot = db
        .collection('movies')
        .doc(slug)
        .collection('rating')
        .where('user', isEqualTo: getCurrentEmail())
        .snapshots();
    return querySnapshot;
  }

  // Kiểm tra phim đã tồn tại hay chưa
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

  // Thêm thông tin phim
  static Future addMovie(
      String name, String slug, String thumbUrl, String posterUrl) async {
    bool existDocument = await checkDocumentExists(slug);
    if (!existDocument) {
      try {
        final DocumentReference documentReference =
            db.collection('movies').doc(slug);
        documentReference.set({
          'name': name,
          'slug': slug,
          'thumb_url': thumbUrl,
          'poster_url': posterUrl,
        });
      } catch (e) {
        log(e.toString());
      }
    }
  }

  // Thêm điểm đánh giá
  static Future addRating(int ratePoint, String name, String slug,
      String thumbUrl, String posterUrl, BuildContext context) async {
    await addMovie(name, slug, thumbUrl, posterUrl);

    final DocumentReference documentReference =
        db.collection('movies').doc(slug).collection('rating').doc();
    try {
      documentReference.set({
        'rate_point': ratePoint,
        'user': getCurrentEmail(),
        'time': Timestamp.now()
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Thao tác thành công!'),
        duration: Duration(seconds: 1),
      ));
    } catch (e) {
      // ignore: use_build_context_synchronously
      QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.error,
          confirmBtnText: 'OK',
          title: 'Có lỗi xảy ra, vui lòng thử lại!');
    }
  }

  // Cập nhật đánh giá
  static Future updateRating(
      int newRatePoint, String docID, String slug, BuildContext context) async {
    final DocumentReference documentReference =
        db.collection('movies').doc(slug).collection('rating').doc(docID);
    try {
      documentReference
          .update({'rate_point': newRatePoint, 'time': Timestamp.now()});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Thao tác thành công!'),
        duration: Duration(seconds: 1),
      ));
    } catch (e) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          confirmBtnText: 'OK',
          title: 'Có lỗi xảy ra, vui lòng thử lại!');
    }
  }

  // Xóa đánh giá
  static Future<void> removeRating(
      String slug, String docID, BuildContext context) async {
    final DocumentReference documentReference =
        db.collection('movies').doc(slug).collection('rating').doc(docID);
    try {
      await documentReference.delete();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Thao tác thành công!'),
        duration: Duration(seconds: 1),
      ));
    } catch (e) {
      log('Failed to delete movie: $e');
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
