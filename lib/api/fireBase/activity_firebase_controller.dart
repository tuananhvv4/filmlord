import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivityFirebaseController {


  final FirebaseFirestore db = FirebaseFirestore.instance;
  final String collectionName = 'activity';

  String getCurrentEmail(){
    return FirebaseAuth.instance.currentUser!.email.toString();
  }


  Stream<QuerySnapshot> activityQuery(){
    final querySnapshot = db.collection('users')
        .doc(getCurrentEmail())
        .collection('activity')
        .orderBy('time',descending: true)
        .snapshots();
    return querySnapshot;
  }



}