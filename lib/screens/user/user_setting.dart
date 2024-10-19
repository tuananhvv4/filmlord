import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

import '../../controller/fireBase/user_firebase_controller.dart';
import 'history_activity.dart';


class UserSetting extends StatefulWidget {
  const UserSetting({super.key});

  @override
  State<UserSetting> createState() => _UserSettingState();
}

class _UserSettingState extends State<UserSetting> {


  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  late String currentUserEmail = '';
  //firebase Controller
  final firebaseController = UserFirebaseController();


  void clearController(){
    _currentPasswordController.clear();
    _newPasswordController.clear();
  }


  // Hiển thị cửa sổ nổi để thay đổi mật khẩu
  void changePassWordDialog(){
    showDialog(context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Color.fromRGBO(46, 46, 46, 1),
            title: const Text('Thay đổi mật khẩu',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22
              ),),

            actions: [
              Column(
                children: [
                  TextField(
                    controller: _currentPasswordController,
                    style: const TextStyle(
                        color: Colors.white
                    ),
                    decoration: InputDecoration(
                      labelText: 'Nhập mật khẩu cũ',
                      labelStyle: const TextStyle(
                        color: Colors.white,
                      ),
                        filled: true,
                        fillColor: Colors.white24,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none
                        ),
                        hintText: 'Nhập mật khẩu cũ',
                        hintStyle: const TextStyle(color: Colors.grey),

                    ),
                  ),
                  const SizedBox(height: 10,),
                  TextField(
                    controller: _newPasswordController,
                    style: const TextStyle(
                        color: Colors.white
                    ),
                    decoration: InputDecoration(
                      labelText: 'Nhập mật khẩu mới',
                      labelStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide.none
                      ),
                      hintText: 'Nhập mật khẩu mới',
                      hintStyle: const TextStyle(color: Colors.grey),

                    ),
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MaterialButton(
                        onPressed: () {
                          submitChangePassword(_currentPasswordController.text.trim(), _newPasswordController.text.trim());
                        },
                        child: const Text('Xác nhận',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15
                        ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                          clearController();
                        },
                        child: const Text('Hủy',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15
                          ),),
                      ),
                    ],
                  ),
                ],
              )
            ],
          );
        },);
  }


  // Xử lý thay đổi mật khẩu
  Future<void> submitChangePassword(String currentPassword, String newPassword) async {
    String titleNotification = '';
    bool checked = true;
    if(currentPassword == newPassword){
      titleNotification = 'Mật khẩu mới phải khác mật khẩu cũ!';
      checked = false;
    }
    if(currentPassword == ''){
      titleNotification = 'Mật khẩu cũ không được để trống!';
      checked = false;
    }
    if(newPassword == ''){
      titleNotification = 'Mật khẩu mới không được để trống!';
      checked = false;
    }
    if(newPassword.length < 6){
      titleNotification = 'Mật khẩu mới phải có ít nhất 6 kí tự!';
      checked = false;
    }
    if(!checked){
      QuickAlert.show(context: context,
          type: QuickAlertType.error,
          title: titleNotification,
          confirmBtnText: 'OK'
      );
    }

    // xử lý mật khẩu
    if(checked){
      bool changedPassword = await firebaseController.changePassword(currentPassword, newPassword, context);
      // Navigator.pop(context);
      if(changedPassword){
        clearController();
      }

    }

  }




  @override
  void initState() {
    // TODO: implement initState
    currentUserEmail = firebaseController.getUser() as String;
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('TÀI KHOẢN'),
        titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
            color: Colors.white
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50)
              ),
              clipBehavior: Clip.hardEdge,
              child: const Image(image: AssetImage('assets/images/avt-profile.png'),
                height: 70,
                width: 70,
                fit: BoxFit.contain,),
            ),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(width: 10,),
            Text(currentUserEmail,
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                fontWeight: FontWeight.w500
              ),),
            const SizedBox(
              height: 30,
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 5, 40, 5),
                  child: Container(
                    height: 50,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white12
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                                  child: Icon(Icons.lock,
                                    color: Colors.white,
                                    size: 22,),
                                ),
                                SizedBox(width: 5,),
                                Text('Thay đổi mật khẩu',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300
                                  ),),
                              ],
                            ),
                            Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: IconButton(
                                  onPressed: () {
                                    changePassWordDialog();
                                  },
                                  icon: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 22,),
                                )
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 5, 40, 5),
                  child: Container(
                    height: 50,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white12
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                                  child: Icon(Icons.history,
                                    color: Colors.white,
                                    size: 22,),
                                ),
                                SizedBox(width: 5,),
                                Text('Hoạt động gần đây',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300
                                  ),),
                              ],
                            ),
                            Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const HistoryActivity(),
                                        transitionsBuilder: (context,
                                            animation,
                                            secondaryAnimation, child) {
                                          const begin = Offset(
                                              1.0, 0.0); // Trượt từ bên trái
                                          const end = Offset.zero;
                                          const curve = Curves.ease;

                                          var tween = Tween(
                                              begin: begin, end: end)
                                              .chain(
                                              CurveTween(curve: curve));
                                          var offsetAnimation =
                                          animation.drive(tween);

                                          return SlideTransition(
                                            position: offsetAnimation,
                                            child: child,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 22,),
                                )
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
