import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:movies_app/screens/movie/movie.dart';
import 'package:movies_app/utilites/helper.dart';
import 'package:shimmer/shimmer.dart';

import '../../api/fireBase/category_firebase_controller.dart';
import '../../controller/GetX/state_controller.dart';
import '../../main.dart';

class CategoryMovieFirebase extends StatefulWidget {
  final String category;
  final String title;

  const CategoryMovieFirebase(
      {super.key, required this.title, required this.category});

  @override
  State<CategoryMovieFirebase> createState() => _CategoryMovieFirebaseState();
}

class _CategoryMovieFirebaseState extends State<CategoryMovieFirebase> {
  //firebase controller
  final firebaseController = CategoryFirebaseController();

  //getX controller
  final stateController = Get.find<StateManager>();

  final ScrollController scrollController = ScrollController();

  void removeItem(String docID) async {
    bool isRemoved = await firebaseController.deleteDocumentWithSubCollections(
        docID, widget.category);
    if (isRemoved) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Thao tác thành công!'),
        duration: Duration(seconds: 1),
      ));
    }
  }

  @override
  void initState() {
    stateController.initRemovingStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
              onPressed: () {
                stateController.updateRemovingStatus();
              },
              icon: Obx(
                () => stateController.isRemovingItem.value
                    ? const Icon(Icons.check)
                    : const Icon(Icons.edit),
              )),
        ],
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder(
        stream: firebaseController.categoryQuery(widget.category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: LoadingAnimationWidget.fourRotatingDots(
                    color: Colors.white, size: 30));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(35, 5, 35, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 80,
                  ),
                  const Text(
                    'Danh sách trống!',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    'Bạn chưa thêm bộ phim nào vào danh sách của mình!',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Image(
                      image: AssetImage('assets/images/category_bg.png'),
                      // fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Navigation(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: double.maxFinite,
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5)),
                          child: const Text(
                            'Khám phá ngay',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                        )),
                  )
                ],
              ),
            );
          }
          QuerySnapshot querySnapshot = snapshot.data!;
          int count = querySnapshot.size;
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return ListView.builder(
            controller: scrollController,
            itemCount: count,
            itemBuilder: (context, index) {
              DocumentSnapshot documentSnapshot = querySnapshot.docs[index];

              return Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    MovieScreen(
                              slug: documentSnapshot['slug'],
                            ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin =
                                  Offset(1.0, 0.0); // Trượt từ bên trái
                              const end = Offset.zero;
                              const curve = Curves.ease;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                        decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                margin: const EdgeInsets.only(right: 5),
                                height: 100,
                                width: 150,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5)),
                                child: CachedNetworkImage(
                                  imageUrl: Helper.handleUrl(
                                      documentSnapshot['thumb_url']),
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
                                  errorWidget: (context, url, error) => const Image(
                                      image: AssetImage(
                                          'assets/images/no-image-landscape.png')),
                                  fit: BoxFit.cover,
                                )),
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.only(top: 5, left: 5),
                              child: Text(
                                documentSnapshot['name'],
                                maxLines: 3,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ))
                          ],
                        ),
                      ),
                    ),
                  ),
                  Obx(() => stateController.isRemovingItem.value
                      ? IconButton(
                          onPressed: () {
                            removeItem(documentSnapshot.id);
                          },
                          icon: const Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                            size: 35,
                          ),
                        )
                      : const SizedBox())
                ],
              );
            },
          );
        },
      ),
    );
  }
}
