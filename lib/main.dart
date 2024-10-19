
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movies_app/controller/GetX/movie_controller.dart';

import 'package:movies_app/screens/navigation/home_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:movies_app/controller/GetX/state_controller.dart';
import 'package:movies_app/screens/navigation/user_page.dart';
import 'package:shared_preferences/shared_preferences.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: 'AIzaSyBwh0WhhcTouQe_yLO_Cm4bOWSwesPPd9w',
        appId: '1:421898503299:android:ee8007bc077c76bf6407b6',
        messagingSenderId: '421898503299',
        projectId: 'moviesapp-f56bf')
    // options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FILMLORD',
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      //   useMaterial3: true,
      // ),
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home:  const Navigation(),
    );
  }
}



class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {

  //getX Controller
  final stateManager = Get.put(StateManager()); //
  final movieController = Get.put(MovieController());


  Future<bool> isUserSignedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
  }


  // Kiểm tra trạng thái đăng nhập
  Future<void> checkLoginStatus() async {
    bool isSignedIn = await isUserSignedIn();

    if (isSignedIn) {
      // Nếu người dùng đã đăng nhập
      stateManager.updateLoginState(true);
    }
  }

  Future<void> clearAllData() async {
    List<String> searchHistory = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    searchHistory = prefs.getStringList('searchHistory') ?? []; // lưu lại lịch sử tìm kiếm
    await prefs.clear(); // Xóa tất cả dữ liệu đã lưu
    await prefs.setStringList('searchHistory', searchHistory);

  }


  int currentPageIndex = 0;

  List<Widget> tabList = const [
    HomePage(),
    // SearchPage(),
    UserPage(),
  ];

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp]);
    // TODO: implement initState
    checkLoginStatus();
    clearAllData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      bottomNavigationBar: BottomNavigationBar(

        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white60,
        selectedItemColor: Colors.white,
        currentIndex: currentPageIndex,
        onTap: (int newIndex){
          setState(() {
            currentPageIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: "Trang chủ",
              icon: Icon(Iconsax.home_1_copy),
            activeIcon: Icon(Iconsax.home),
              ),
          // BottomNavigationBarItem(
          //     label: "Tìm kiếm",
          //     icon: Icon(Iconsax.search_normal_1_copy),
          //   activeIcon: Icon(Iconsax.search_normal_1)
          // ),
          BottomNavigationBarItem(
              label: "Người dùng",
              icon: Icon(Iconsax.user_tag_copy),
        activeIcon: Icon(Iconsax.user_tag)
          ),
        ],
      ),
      body: IndexedStack(
        index: currentPageIndex,
        children: tabList,
      )
    );
  }
}
