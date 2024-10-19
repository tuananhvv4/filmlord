import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:quickalert/quickalert.dart';

class UserFirebaseController {
  final currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore db = FirebaseFirestore.instance;


  String? getUser() {
    return currentUser!.email;
  }


  // Kiểm tra mật khẩu đã nhập có khớp với mật khẩu hiện tại hay không ?
  Future<bool> checkCurrentPassword(String currentPassword) async {
    try{
      final credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: currentPassword,
      );
      await currentUser!.reauthenticateWithCredential(credential);
      return true;
    }catch(e){
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword,String newPassword, BuildContext context) async {
    bool passwordMatches = await checkCurrentPassword(currentPassword);

    //Nếu nhập đúng mật khẩu cũ
    if(passwordMatches){
      try{
        await currentUser!.updatePassword(newPassword);
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        // Navigator.pop(context);
        QuickAlert.show(
            // ignore: use_build_context_synchronously
            context: context,
            type: QuickAlertType.success,
        confirmBtnText: 'OK',
        title: 'Thay đổi mật khẩu thành công');
        return true;
      }catch(e){
        log(e.toString());
        return false;
      }
    }else{
      //Nếu nhập sai mật khẩu cũ
      // Navigator.pop(context);
      QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.error,
          confirmBtnText: 'OK',
          title: 'Mật khẩu cũ không chính xác, vui lòng thử lại!');
      return false;
    }
  }

  Future<bool> userSignUp(String email, String password, BuildContext context) async {

    final CollectionReference user = db.collection('users');
    final DocumentReference documentReference = user.doc(email);
    try{

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email, password: password);
      await documentReference.set({
        'email' : email,
        'time' : Timestamp.now()
      });
      return true;
      // ignore: empty_catches
    } on FirebaseAuthException catch(e){
      String message = '';
      switch(e.code){
        case 'weak-password': {
          message = 'Mật khẩu quá ngắn!';
          break;
        }
        case 'email-already-in-use': {
          message = 'Email đã được sử dụng!';
          break;
        }
        case 'invalid-email': {
          message = 'Email không hợp lệ';
          break;
        }
        default: {
          message = e.code.toString();
        }
      }
      // ignore: use_build_context_synchronously
      QuickAlert.show(context: context,
          type: QuickAlertType.error,
          title: message,
          confirmBtnText: 'OK');
      return false;
      // weak-password: mật khẩu quá ngắn
      // email-already-in-use: email đã được dùng
      // invalid-email: email k hợp lệ
    }
  }
}