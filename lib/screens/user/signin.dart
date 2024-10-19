import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:movies_app/screens/user/forgetPassword.dart';
import 'package:quickalert/quickalert.dart';

import '../../controller/GetX/state_controller.dart';


class SignInPage extends StatefulWidget {
  final VoidCallback showSignInPage;
  const SignInPage({super.key, required this.showSignInPage});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  // GetX
  final stateController = Get.find<StateManager>();

  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  bool hideText = true;
  bool isButtonDisabled = false;

  Future signIn() async {
    String message = '';
    if(_emailController.text.trim().isEmpty || _passController.text.trim().isEmpty){
      message = 'Vui lòng điền vào trường văn bản còn thiếu!' ;
    }else{
      setState(() {
        isButtonDisabled = true;
      });
      // showDialog(context: context, builder: (context) => Center(child: CircularProgressIndicator(),),);
      try{
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passController.text.trim());
        if(!stateController.loginState.value){
          await stateController.updateLoginState(true);
        }
        Navigator.pop(context);
      } on FirebaseAuthException catch(e){

        switch(e.code){
          case 'invalid-email': {
            message = 'Email không hợp lệ!';
            break;
          }
          case 'invalid-credential': {
            message = 'Email hoặc mật khẩu không đúng!';
            break;
          }
          case 'too-many-requests': {
            message = 'Tài khoản tạm thời bị khóa do nhập sai quá nhiều lần! Vui lòng sử dụng chức năng quên mật khẩu hoặc thử lại sau ít phút!';
            break;
          }
          default: {
            message = e.code.toString();
          }
        }

        // channel-error: email trống
        // invalid-email: email k hợp lệ
        //invalid-credential: email hoặc pass k đúng
      }

      await Future.delayed(const Duration(seconds: 2));
      if(mounted){
        setState(() {
          isButtonDisabled = false;
        });
      }
    }


    if(message.isNotEmpty){
      QuickAlert.show(context: context,
          type: QuickAlertType.error,
          title: message,
          confirmBtnText: 'OK');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Stack(
          children: [
            Positioned(
              top: 60,
              width: MediaQuery.of(context).size.width,
              child: const Image(
                image: AssetImage('assets/images/bg_img.jpg'),
                // fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 60,
              height: 330,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(1.0),
                          Colors.black.withOpacity(0.90),
                          Colors.black.withOpacity(0.65),
                          Colors.black.withOpacity(0.65),
                          Colors.black.withOpacity(0.65),
                          Colors.black.withOpacity(0.65),
                          Colors.black.withOpacity(0.60),
                          Colors.black.withOpacity(0.50),
                          Colors.black.withOpacity(0.50),
                          Colors.black.withOpacity(0.70),
                          Colors.black.withOpacity(1),
                        ])),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  const Text(
                    'Chào mừng trở lại',
                    style: TextStyle(color: Colors.white, fontSize: 30,fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Đăng nhập ngay để tiếp tục theo dõi và tận hưởng các bộ phim mà bạn yêu thích!',
                    style: TextStyle(color: Colors.white, fontSize: 14,fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    alignment: Alignment.center,
                    // decoration: BoxDecoration(
                    //     color: Colors.white12,
                    //     borderRadius: BorderRadius.circular(5)),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.email),
                              prefixIconColor: Colors.white,
                              hintText: 'Email',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder()
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 10,),
                        TextField(
                          controller: _passController,
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              prefixIconColor: Colors.white,
                              hintText: 'Mật khẩu',
                              hintStyle: const TextStyle(color: Colors.white70),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    hideText = !hideText;
                                  });
                                },
                                icon: hideText ?  Icon(Iconsax.eye_slash) : Icon(Iconsax.eye),
                                color: Colors.white,
                              )),
                          obscureText: hideText? true : false,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => ForgetPassword(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.ease;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));
                              var offsetAnimation =
                              animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },),);
                    },
                    style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
                    child: const Text(
                      'Quên mật khẩu?',
                      style: TextStyle(color: Colors.white,fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Container(
                    margin: const EdgeInsets.only(left: 80,right: 80),
                    alignment: Alignment.center,
                      height: 45,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5)),
                      child: TextButton(
                        onPressed: isButtonDisabled? null : signIn,

                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0),),
                        child: Container(
                            alignment: Alignment.center,
                            child: isButtonDisabled? LoadingAnimationWidget.waveDots(color: Colors.black, size: 20)
                                : const Text(
                              'ĐĂNG NHẬP',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.black),
                            )
                        ),
                      )),
                  const SizedBox(
                    height: 40,
                  ),
                  const Text(
                    'Bạn chưa có tài khoản?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    onPressed: widget.showSignInPage,
                    style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
                    child: const Text(
                      'Tạo tài khoản',
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
