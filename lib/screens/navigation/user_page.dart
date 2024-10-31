import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:movies_app/screens/user/user_setting.dart';
import 'package:shimmer/shimmer.dart';

import '../../controller/GetX/state_controller.dart';
import '../../api/fireBase/favorite_firebase_controller.dart';
import '../../api/fireBase/history_firebase_controller.dart';
import '../category/category_movie_firebase.dart';
import '../movie/movie.dart';
import '../user/common.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  // GetX
  final stateController = Get.find<StateManager>();

  Future logout() async {
    stateController.updateLoginState(false);
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Common(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const SizedBox(
            child: Image(
              image: AssetImage('assets/images/logo.png'),
              height: 60,
              width: 140,
              fit: BoxFit.contain,
            ),
          ),
          actions: [
            Obx(
              () => stateController.loginState.value
                  ? Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor:
                                  const Color.fromRGBO(46, 46, 46, 1),
                              builder: (context) {
                                return Container(
                                  height: 120,
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          height: 5,
                                          width: 40,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder: (context,
                                                          animation,
                                                          secondaryAnimation) =>
                                                      const UserSetting(),
                                                  transitionsBuilder: (context,
                                                      animation,
                                                      secondaryAnimation,
                                                      child) {
                                                    const begin = Offset(1.0,
                                                        0.0); // Trượt từ bên trái
                                                    const end = Offset.zero;
                                                    const curve = Curves.ease;

                                                    var tween = Tween(
                                                            begin: begin,
                                                            end: end)
                                                        .chain(CurveTween(
                                                            curve: curve));
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
                                            child: const Row(
                                              children: [
                                                Icon(
                                                  Iconsax.profile_circle,
                                                  color: Colors.blueAccent,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  'Tài khoản',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white),
                                                )
                                              ],
                                            )),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              logout();
                                            },
                                            child: const Row(
                                              children: [
                                                Icon(
                                                  Icons.logout,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  'Đăng xuất',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white),
                                                )
                                              ],
                                            ))
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(
                            Iconsax.menu_1,
                            color: Colors.white,
                            size: 25,
                          )),
                    )
                  : const SizedBox(),
            )
          ],
        ),
        backgroundColor: Colors.black,
        body: Obx(() => stateController.loginState.value
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FavoriteFirebaseController.favoriteQuery(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return Column(
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.fromLTRB(10, 10, 5, 10),
                                height: 35,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'DANH SÁCH PHIM CỦA BẠN',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  const CategoryMovieFirebase(
                                                title: 'DANH SÁCH PHIM CỦA BẠN',
                                                category: 'favorite',
                                              ),
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                const begin = Offset(1.0,
                                                    0.0); // Trượt từ bên trái
                                                const end = Offset.zero;
                                                const curve = Curves.ease;

                                                var tween = Tween(
                                                        begin: begin, end: end)
                                                    .chain(CurveTween(
                                                        curve: curve));
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
                                        icon: const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white,
                                          size: 18,
                                        ))
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              )
                            ],
                          );
                        } else {
                          QuerySnapshot querySnapshot = snapshot.data!;
                          int count = querySnapshot.size;
                          return Column(
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.fromLTRB(10, 10, 5, 10),
                                height: 35,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'DANH SÁCH PHIM CỦA BẠN',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  const CategoryMovieFirebase(
                                                title: 'DANH SÁCH PHIM CỦA BẠN',
                                                category: 'favorite',
                                              ),
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                const begin = Offset(1.0,
                                                    0.0); // Trượt từ bên trái
                                                const end = Offset.zero;
                                                const curve = Curves.ease;

                                                var tween = Tween(
                                                        begin: begin, end: end)
                                                    .chain(CurveTween(
                                                        curve: curve));
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
                                        icon: const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white,
                                          size: 18,
                                        ))
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: count,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot documentSnapshot =
                                        querySnapshot.docs[index];
                                    return Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      width: 130,
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5)),
                                          color: Colors.grey.shade100),
                                      alignment: Alignment.centerLeft,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  MovieScreen(
                                                slug: documentSnapshot['slug'],
                                              ),
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                const begin = Offset(1.0, 0.0);
                                                const end = Offset.zero;
                                                const curve = Curves.ease;

                                                var tween = Tween(
                                                        begin: begin, end: end)
                                                    .chain(CurveTween(
                                                        curve: curve));
                                                var offsetAnimation =
                                                    animation.drive(tween);

                                                return SlideTransition(
                                                  position: offsetAnimation,
                                                  child: child,
                                                );
                                              },
                                            ),
                                          );

                                          // Navigator.pushNamed(context,'/movieDetail',arguments: newMoviesList[index].slug);
                                        },
                                        child: Container(
                                          height: 250,
                                          width: 250,
                                          clipBehavior: Clip.hardEdge,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                documentSnapshot['poster_url'],
                                            placeholder: (context, url) =>
                                                Shimmer.fromColors(
                                              baseColor: Colors.grey,
                                              highlightColor: Colors.white,
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: Colors.black26,
                                                ),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: HistoryFirebaseController.historyQuery(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return Column(
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.fromLTRB(10, 10, 5, 10),
                                height: 35,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'XEM GẦN ĐÂY',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  const CategoryMovieFirebase(
                                                title: 'XEM GẦN ĐÂY',
                                                category: 'history',
                                              ),
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                const begin = Offset(1.0,
                                                    0.0); // Trượt từ bên trái
                                                const end = Offset.zero;
                                                const curve = Curves.ease;

                                                var tween = Tween(
                                                        begin: begin, end: end)
                                                    .chain(CurveTween(
                                                        curve: curve));
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
                                        icon: const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white,
                                          size: 18,
                                        ))
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              )
                            ],
                          );
                        } else {
                          QuerySnapshot querySnapshot = snapshot.data!;
                          int count = querySnapshot.size;
                          return Column(
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.fromLTRB(10, 10, 5, 10),
                                height: 35,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'XEM GẦN ĐÂY',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  const CategoryMovieFirebase(
                                                title: 'XEM GẦN ĐÂY',
                                                category: 'history',
                                              ),
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                const begin = Offset(1.0,
                                                    0.0); // Trượt từ bên trái
                                                const end = Offset.zero;
                                                const curve = Curves.ease;

                                                var tween = Tween(
                                                        begin: begin, end: end)
                                                    .chain(CurveTween(
                                                        curve: curve));
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
                                        icon: const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white,
                                          size: 18,
                                        ))
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: count,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot documentSnapshot =
                                        querySnapshot.docs[index];
                                    return Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      width: 130,
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5)),
                                          color: Colors.grey.shade100),
                                      alignment: Alignment.centerLeft,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  MovieScreen(
                                                slug: documentSnapshot['slug'],
                                              ),
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                const begin = Offset(1.0, 0.0);
                                                const end = Offset.zero;
                                                const curve = Curves.ease;

                                                var tween = Tween(
                                                        begin: begin, end: end)
                                                    .chain(CurveTween(
                                                        curve: curve));
                                                var offsetAnimation =
                                                    animation.drive(tween);

                                                return SlideTransition(
                                                  position: offsetAnimation,
                                                  child: child,
                                                );
                                              },
                                            ),
                                          );

                                          // Navigator.pushNamed(context,'/movieDetail',arguments: newMoviesList[index].slug);
                                        },
                                        child: Container(
                                          height: 250,
                                          width: 250,
                                          clipBehavior: Clip.hardEdge,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                documentSnapshot['poster_url'],
                                            placeholder: (context, url) =>
                                                Shimmer.fromColors(
                                              baseColor: Colors.grey,
                                              highlightColor: Colors.white,
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: Colors.black26,
                                                ),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              )
            : Stack(
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
                  Positioned(
                    top: 250,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Đăng nhập ngay để tiếp tục theo dõi và tận hưởng các bộ phim mà bạn yêu thích!',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Container(
                            alignment: Alignment.center,
                            // decoration: BoxDecoration(
                            //     color: Colors.white12,
                            //     borderRadius: BorderRadius.circular(5)),
                          ),
                          Container(
                              margin:
                                  const EdgeInsets.only(left: 80, right: 80),
                              alignment: Alignment.center,
                              height: 45,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5)),
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            const Common(),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          const begin = Offset(1.0, 0.0);
                                          const end = Offset.zero;
                                          const curve = Curves.ease;

                                          var tween = Tween(
                                                  begin: begin, end: end)
                                              .chain(CurveTween(curve: curve));
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
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.all(0),
                                  ),
                                  child: const Text(
                                    'ĐĂNG NHẬP NGAY',
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.black),
                                  ))),
                        ],
                      ),
                    ),
                  )
                ],
              )));
  }
}
