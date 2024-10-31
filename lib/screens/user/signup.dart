import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../controller/GetX/state_controller.dart';
import '../../api/fireBase/user_firebase_controller.dart';

class SignUpPage extends StatefulWidget {
  final VoidCallback showSignUpPage;
  const SignUpPage({super.key, required this.showSignUpPage});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _rePassController = TextEditingController();

  // GetX
  final stateController = Get.find<StateManager>();

  bool hideText = true;
  bool isButtonDisabled = false;

  Future signUp() async {
    String message = '';

    if (_emailController.text.trim().isEmpty ||
        _passController.text.trim().isEmpty ||
        _rePassController.text.trim().isEmpty) {
      message = 'Vui lòng điền vào trường văn bản còn thiếu!';
    } else if (_passController.text.trim().length < 6) {
      message = 'Mật khẩu phải có ít nhất 6 kí tự!';
    } else if (_passController.text.trim() != _rePassController.text.trim()) {
      message = 'Mật khẩu đã nhập không khớp!';
    } else {
      setState(() {
        isButtonDisabled = true;
      });

      bool isSuccess = await UserFirebaseController.userSignUp(
          _emailController.text.trim(), _passController.text.trim(), context);
      if (isSuccess) {
        stateController.updateLoginState(true);
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }

      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        isButtonDisabled = false;
      });
    }

    if (message.isNotEmpty) {
      QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.error,
          title: message,
          confirmBtnText: 'OK');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passController.dispose();
    _rePassController.dispose();
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
                    'Đăng ký',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Đăng ký ngay để theo dõi và tận hưởng kho phim cực khủng từ FILMLORD!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w300),
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
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
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
                                icon: hideText
                                    ? const Icon(Iconsax.eye_slash)
                                    : const Icon(Iconsax.eye),
                                color: Colors.white,
                              )),
                          obscureText: hideText ? true : false,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: _rePassController,
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              prefixIconColor: Colors.white,
                              hintText: 'Nhập lại Mật khẩu',
                              hintStyle: const TextStyle(color: Colors.white70),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    hideText = !hideText;
                                  });
                                },
                                icon: hideText
                                    ? const Icon(Iconsax.eye_slash)
                                    : const Icon(Iconsax.eye),
                                color: Colors.white,
                              )),
                          obscureText: hideText ? true : false,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Container(
                      margin: const EdgeInsets.only(left: 80, right: 80),
                      alignment: Alignment.center,
                      height: 45,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5)),
                      child: TextButton(
                        onPressed: isButtonDisabled ? null : signUp,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                        ),
                        child: Container(
                            alignment: Alignment.center,
                            child: isButtonDisabled
                                ? LoadingAnimationWidget.waveDots(
                                    color: Colors.black, size: 20)
                                : const Text(
                                    'ĐĂNG KÝ',
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.black),
                                  )),
                      )),
                  const SizedBox(
                    height: 40,
                  ),
                  const Text(
                    'Đã có tài khoản?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    onPressed: widget.showSignUpPage,
                    style:
                        TextButton.styleFrom(padding: const EdgeInsets.all(0)),
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
