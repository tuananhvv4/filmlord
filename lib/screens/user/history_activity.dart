import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:movies_app/screens/movie/movie.dart';

import '../../api/fireBase/activity_firebase_controller.dart';
import '../../controller/GetX/state_controller.dart';
import '../../main.dart';

class HistoryActivity extends StatefulWidget {
  const HistoryActivity({super.key});

  @override
  State<HistoryActivity> createState() => _HistoryActivityState();
}

class _HistoryActivityState extends State<HistoryActivity> {
  //firebase controller
  final activityController = ActivityFirebaseController();

  //getX controller
  final stateController = Get.find<StateManager>();

  final ScrollController scrollController = ScrollController();

  String formatElapsedTime(Timestamp commentTime) {
    final currentTime = DateTime.now();
    final commentDateTime = commentTime.toDate();
    final difference = currentTime.difference(commentDateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
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
        title: const Text('HOẠT ĐỘNG GẦN ĐÂY'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         stateController.updateRemovingStatus();
        //       },
        //       icon: Obx(() => stateController.isRemovingItem.value
        //           ? const Icon(Icons.check)
        //           : const Icon(Icons.edit),)
        //   ),
        // ],
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder(
        stream: activityController.activityQuery(),
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
                    'Chưa hoạt động nào!',
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
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            // Lấy danh sách các hoạt động
            final activities = snapshot.data!.docs;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activityData = activities[index];

                final Timestamp activityTime =
                    activityData['time'] ?? Timestamp.now();

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            MovieScreen(slug: activityData['slug']),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0); // Trượt từ bên trái
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
                    color: Colors.white12,
                    margin: const EdgeInsets.only(bottom: 5),
                    child: ListTile(
                      title: Text(
                        activityData['content'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Phim: ${activityData['movie']}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w300),
                      ),
                      trailing: Text(formatElapsedTime(
                          activityTime)), // Hiển thị thời gian comment theo yêu cầu
                    ),
                  ),
                );
              },
            );
          }
          return Text(snapshot.error.toString());
        },
      ),
    );
  }
}
