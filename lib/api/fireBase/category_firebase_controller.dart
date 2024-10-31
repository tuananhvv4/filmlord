import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryFirebaseController {

  final FirebaseFirestore db = FirebaseFirestore.instance;

  String getCurrentEmail(){
    return FirebaseAuth.instance.currentUser!.email.toString();
  }


  Stream<QuerySnapshot> categoryQuery(String category){
    final querySnapshot = db.collection('users')
        .doc(getCurrentEmail())
        .collection(category)
        .orderBy('time',descending: true)
        .snapshots();
    return querySnapshot;
  }
  Future<bool> deleteDocumentWithSubCollections(String docID, String category) async {
    try {
      // Lấy tài liệu cần xóa
      final documentRef = db.collection('users')
          .doc(getCurrentEmail())
          .collection(category)
          .doc(docID);

      if(category == 'history'){
        // Xóa các tài liệu trong subcollections (nếu biết tên subcollections)
        final subCollections = ['episodes']; // Tên subcollections
        for (final subCollectionName in subCollections) {
          final subCollectionRef = documentRef.collection(subCollectionName);
          final subCollectionDocs = await subCollectionRef.get();
          for (final doc in subCollectionDocs.docs) {
            await doc.reference.delete();
          }
        }
      }
      // Xóa tài liệu gốc
      await documentRef.delete();

      log('Tài liệu và subcollections đã được xóa thành công!');
      return true;
    } catch (e) {
      log('Lỗi khi xóa tài liệu: $e');
      return false;
    }
  }

  Future<bool> removeItem(String docID, String category) async {
    final DocumentReference documentReference = db.collection('users')
        .doc(getCurrentEmail())
        .collection(category)
        .doc(docID);
    try {
      await documentReference.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

}