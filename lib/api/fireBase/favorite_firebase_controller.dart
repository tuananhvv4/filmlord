import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteFirebaseController {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static String getCurrentEmail() {
    return FirebaseAuth.instance.currentUser!.email.toString();
  }

  static Stream<QuerySnapshot> isFavoriteQuery(String slug) {
    final querySnapshot = db
        .collection('users')
        .doc(getCurrentEmail())
        .collection('favorite')
        .where('slug', isEqualTo: slug)
        .snapshots();
    return querySnapshot;
  }

  static Stream<QuerySnapshot> favoriteQuery() {
    final querySnapshot = db
        .collection('users')
        .doc(getCurrentEmail())
        .collection('favorite')
        .limit(10)
        .snapshots();
    return querySnapshot;
  }

  static Future addFavoriteMovie(
      String name, String slug, String thumbUrl, String posterUrl) async {
    final DocumentReference documentReference = db
        .collection('users')
        .doc(getCurrentEmail())
        .collection('favorite')
        .doc(slug);
    try {
      documentReference.set({
        'name': name,
        'slug': slug,
        'thumb_url': thumbUrl,
        'poster_url': posterUrl,
        'time': Timestamp.now()
      });
    } catch (e) {
      log(e.toString());
    }
  }

  static Future<void> removeFavoriteMovie(String docID) async {
    final DocumentReference documentReference = db
        .collection('users')
        .doc(getCurrentEmail())
        .collection('favorite')
        .doc(docID);
    try {
      await documentReference.delete();
    } catch (e) {
      log('Failed to delete movie: $e');
    }
  }

  static Future addRecommend(
      String name, String slug, String thumbUrl, String posterUrl) async {
    final DocumentReference documentReference =
        db.collection('recommendMovies').doc(slug);
    try {
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
