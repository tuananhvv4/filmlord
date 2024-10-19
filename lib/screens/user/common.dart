import 'package:flutter/material.dart';
import 'package:movies_app/screens/user/signin.dart';
import 'package:movies_app/screens/user/signup.dart';

class Common extends StatefulWidget {
  const Common({super.key});

  @override
  State<Common> createState() => _CommonState();
}

class _CommonState extends State<Common> {

  bool showLoginPage = true;

  void changeState(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(showLoginPage){
      return SignInPage(showSignInPage: changeState,);
    }else{
      return SignUpPage(showSignUpPage: changeState,);
    }
  }
}
