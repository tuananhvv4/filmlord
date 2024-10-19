import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quickalert/quickalert.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final _emailController = TextEditingController();

  bool isButtonDisabled = false;

  Future resetPassword() async {
    String message = '';
    if(_emailController.text.trim().isEmpty){
      message = 'Email không được để trống!' ;
    }else{
      setState(() {
        isButtonDisabled = true;
      });
      // showDialog(context: context, builder: (context) => Center(child: CircularProgressIndicator(),),);
      try{
        await FirebaseAuth.instance.sendPasswordResetEmail(
            email: _emailController.text.trim());
            message = 'Một email để đặt lại mật khẩu đã được gửi đến ${_emailController.text.trim()}. Vui lòng kiểm tra!' ;
      } on FirebaseAuthException catch(e){

        switch(e.code){
          case 'invalid-email': {
            message = 'Email không hợp lệ!';
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
                    'Quên mật khẩu',
                    style: TextStyle(color: Colors.white, fontSize: 30,fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Nhập email của bạn vào ô bên dưới để đặt lại mật khẩu!',
                    style: TextStyle(color: Colors.white, fontSize: 14,fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Container(
                    alignment: Alignment.center,
                    // decoration: BoxDecoration(
                    //     color: Colors.white12,
                    //     borderRadius: BorderRadius.circular(5)),
                    child: Column(
                      children: [
                        Container(
                          // decoration: BoxDecoration(
                          //   borderRadius: BorderRadius.circular(15),
                          //   color: Colors.black87,
                          // ),
                          child: TextField(
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
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30,),
                  Container(
                      margin: const EdgeInsets.only(left: 80,right: 80),
                      alignment: Alignment.center,
                      height: 45,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5)),
                      child: TextButton(
                        onPressed: isButtonDisabled? null : resetPassword,

                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(0),),
                        child: Container(
                            alignment: Alignment.center,
                            child: isButtonDisabled? LoadingAnimationWidget.waveDots(color: Colors.black, size: 20)
                                : const Text(
                              'XÁC NHẬN',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.black),
                            )
                        ),
                      )),
                ],
              ),
            )
          ],
        ));
  }
}
