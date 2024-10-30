import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:movies_app/controller/fireBase/favorite_firebase_controller.dart';
import 'package:movies_app/controller/fireBase/history_firebase_controller.dart';
import 'package:movies_app/controller/fireBase/rating_firebase_controller.dart';
import 'package:movies_app/screens/movie/videoPlayer/flick_full_screen_custom.dart';
import 'package:movies_app/screens/user/common.dart';
import 'package:movies_app/controller/GetX/state_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../controller/GetX/movie_controller.dart';
import '../../model/detail_movie.dart';

class MovieDetail extends StatefulWidget {
  final Movie movieDetail;
  final List<ServerData> episodesList;
  final List<String> categoriesList;
  final List<String> episodeNameList;
  final List<String> videoUrlList;

  const MovieDetail(
      {super.key,
      required this.movieDetail,
      required this.episodesList,
      required this.categoriesList,
      required this.episodeNameList,
      required this.videoUrlList});

  @override
  State<MovieDetail> createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  //GetX Controller
  final stateController = Get.find<StateManager>();
  final movieController = Get.find<MovieController>();

  // Firebase
  final historyController = HistoryFirebaseController();
  final favoriteController = FavoriteFirebaseController();
  final ratingController = RatingFirebaseController();

  // scroll controller
  final scrollController = ScrollController();

  bool isLoading = true;

  int baseLineTitle = 1;
  int maxLineTitle = 5;

  int baseLineDescription = 5;
  int maxLineDescription = 10;

  List<String> ratingNameList = ['Tệ', 'Bình Thường', 'Tuyệt vời'];
  List<IconData> ratingIconList = [
    Icons.sentiment_dissatisfied_outlined,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied,
  ];

  late String trailerUrlEmbed;
  late final WebViewController webViewController;

  String filterText(String input) {
    String noHtmlTags = input.replaceAll(RegExp(r'<[^>]+>'), '');
    String filteredText = noHtmlTags.replaceAll(
      RegExp(
          r'[^a-zA-Z0-9ÀÁÂÃÈÉẺÊÌÍÒÓÔÕÙÚĂĐĨŨƯƠÝYàáâãèéêìíòóôõùúăđĩũươẠ-ỹýy.,!? ]'),
      '',
    );
    return filteredText;
  }

  @override
  void initState() {
    // TODO: implement initState
    stateController.initShowTitleStatus();
    stateController.initShowDescriptionStatus();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // stateController.dispose();
    // movieController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    margin: const EdgeInsets.only(bottom: 15, top: 10),
                    child: GestureDetector(
                      onTap: () {
                        stateController.updateShowTitleStatus();
                      },
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.decelerate,
                        child: Obx(
                          () => Text(
                            widget.movieDetail.name.toString(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: stateController.showMoreTitle.value
                                ? maxLineTitle
                                : baseLineTitle,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    )),
                Row(
                  children: [
                    Text(widget.movieDetail.year.toString(),
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w400)),
                    const SizedBox(
                      width: 15,
                      child: Center(
                          child: Text('|',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400))),
                    ),
                    Text(widget.movieDetail.country![0].name.toString(),
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w400)),
                    const SizedBox(
                      width: 15,
                      child: Center(
                          child: Text('|',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400))),
                    ),
                    Text(widget.movieDetail.quality.toString(),
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w400)),
                    const SizedBox(
                      width: 15,
                      child: Center(
                          child: Text('|',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400))),
                    ),
                    Text(widget.movieDetail.lang.toString(),
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w400)),
                  ],
                ),
                Obx(
                  () => stateController.loginState.value
                      ? StreamBuilder(
                          stream: historyController
                              .episodeQuery(widget.movieDetail.slug.toString()),
                          builder: (context, snapshot) {
                            // Kiểm tra trạng thái kết nối
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                  padding: const EdgeInsets.only(
                                      left: 150, right: 150),
                                  child: LoadingAnimationWidget.prograssiveDots(
                                      color: Colors.white, size: 20));
                            }

                            if (snapshot.hasError) {
                              return const Center(
                                  child: Text('Có lỗi xảy ra!'));
                            }

                            //  nếu có dữ liệu
                            if (snapshot.hasData &&
                                snapshot.data!.docs.isNotEmpty) {
                              final document = snapshot.data!.docs.first;
                              var data =
                                  document.data() as Map<String, dynamic>;

                              return Container(
                                margin:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: TextButton(
                                  onPressed: () {
                                    // Lưu vị trí đang xem

                                    movieController.setSeekTime(
                                        data['currentWatchingTime']);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LandscapePlayer(
                                          currentIndex: data['index'],
                                          videoUrlList: widget.videoUrlList,
                                          movieDetail: widget.movieDetail,
                                          movieEpisodeNameList:
                                              widget.episodeNameList,
                                        ),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    backgroundColor: Colors.white,
                                    minimumSize:
                                        const Size(double.maxFinite, 45),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.play_arrow,
                                        color: Colors.black,
                                      ),
                                      widget.movieDetail.episodeCurrent ==
                                              'Full'
                                          ? const Text(
                                              'Tiếp tục xem',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            )
                                          : Text(
                                              'Tiếp tục xem - ${data['episodeName']}',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              // đã đăng nhập nhưng không có dữ liệu phim
                              return Container(
                                margin:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: TextButton(
                                  onPressed: () async {
                                    await historyController.addEpisode(
                                        widget.movieDetail.name.toString(),
                                        widget.movieDetail.slug.toString(),
                                        widget.movieDetail.thumbUrl.toString(),
                                        widget.movieDetail.posterUrl.toString(),
                                        widget.episodesList[0].linkM3u8
                                            .toString(),
                                        widget.episodesList[0].name.toString(),
                                        0);
                                    Navigator.push(
                                      // ignore: use_build_context_synchronously
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LandscapePlayer(
                                          currentIndex: 0,
                                          movieDetail: widget.movieDetail,
                                          videoUrlList: widget.videoUrlList,
                                          movieEpisodeNameList:
                                              widget.episodeNameList,
                                        ),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    backgroundColor: Colors.white,
                                    minimumSize:
                                        const Size(double.maxFinite, 45),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.play_arrow,
                                        color: Colors.black,
                                      ),
                                      Text(
                                        'Xem ngay',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        )
                      : Container(
                          margin: const EdgeInsets.only(top: 10, bottom: 10),
                          child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LandscapePlayer(
                                        currentIndex: 0,
                                        movieDetail: widget.movieDetail,
                                        videoUrlList: widget.videoUrlList,
                                        movieEpisodeNameList:
                                            widget.episodeNameList,
                                      ),
                                    ));
                              },
                              style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  backgroundColor: Colors.white,
                                  minimumSize:
                                      const Size(double.maxFinite, 45)),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_arrow,
                                    color: Colors.black,
                                  ),
                                  Text('Xem ngay',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400))
                                ],
                              )),
                        ),
                ),
                GestureDetector(
                  onTap: () {
                    stateController.updateShowDescriptionStatus();
                  },
                  child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.decelerate,
                      child: Obx(
                        () {
                          String filteredText =
                              filterText(widget.movieDetail.content.toString());
                          return Text(
                            filteredText,
                            maxLines: stateController.showMoreDescription.value
                                ? maxLineDescription
                                : baseLineDescription,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      )),
                ),
                SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      const Text('Diễn viên:',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          widget.movieDetail.actor!.join(', ').toString(),
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              overflow: TextOverflow.ellipsis),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      const Text('Đạo diễn:',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          widget.movieDetail.director!.join(', ').toString(),
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              overflow: TextOverflow.ellipsis),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      const Text('Thể loại:',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          widget.categoriesList.join(', ').toString(),
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              overflow: TextOverflow.ellipsis),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    children: [
                      // Nút thêm vào danh sách yêu thích
                      Obx(
                        () => stateController.loginState.value
                            // nếu đã đăng nhập
                            ? StreamBuilder<QuerySnapshot>(
                                stream: favoriteController.isFavoriteQuery(
                                    widget.movieDetail.slug.toString()),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final documents = snapshot.data!.docs;
                                    bool hasMovie = documents.isNotEmpty;

                                    return TextButton(
                                      onPressed: () {
                                        if (hasMovie) {
                                          favoriteController
                                              .removeFavoriteMovie(
                                                  documents.first.id);
                                        } else {
                                          favoriteController.addFavoriteMovie(
                                            widget.movieDetail.name.toString(),
                                            widget.movieDetail.slug.toString(),
                                            widget.movieDetail.thumbUrl
                                                .toString(),
                                            widget.movieDetail.posterUrl
                                                .toString(),
                                          );
                                        }
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text('Thao tác thành công!'),
                                          duration: Duration(seconds: 1),
                                        ));
                                      },
                                      style: TextButton.styleFrom(
                                          // fixedSize: Size(50, 50)
                                          ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 250),
                                            child: Icon(
                                              hasMovie
                                                  ? Icons.check
                                                  : Icons.add,
                                              color: Colors.white,
                                              key: ValueKey<bool>(
                                                  hasMovie), // Đảm bảo AnimatedSwitcher nhận diện widget mới
                                            ),
                                          ),
                                          const Text(
                                            'Danh sách',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return const Column(
                                      children: [
                                        Text(
                                          'Danh sách',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              )
                            // nếu chưa đăng nhập
                            : TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Common(),
                                      ));
                                },
                                style: TextButton.styleFrom(
                                    // fixedSize: Size(50, 50)
                                    ),
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Colors
                                          .white, // Đảm bảo AnimatedSwitcher nhận diện widget mới
                                    ),
                                    Text(
                                      'Danh sách',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      // Nút đánh giá phim
                      Obx(() => stateController.loginState.value
                          ? StreamBuilder<QuerySnapshot>(
                              stream: ratingController.ratingQuery(
                                  widget.movieDetail.slug.toString()),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Lỗi: ${snapshot.error}'));
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: Colors
                                            .white, // Đảm bảo AnimatedSwitcher nhận diện widget mới
                                      ),
                                      Text(
                                        'Danh sách',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                // Lấy danh sách document từ snapshot
                                final documents = snapshot.data!.docs;

                                // nếu chưa có đánh giá
                                if (documents.isEmpty) {
                                  return CustomPopup(
                                      backgroundColor:
                                          const Color.fromRGBO(51, 51, 51, 1),
                                      contentPadding: const EdgeInsets.all(0),
                                      content: SizedBox(
                                          height: 70,
                                          width: 300,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            // Căn đều các phần tử
                                            children: ratingNameList
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              int index = entry
                                                  .key; // Lấy chỉ số từ entry
                                              String ratingName = entry
                                                  .value; // Lấy giá trị tên đánh giá từ entry

                                              return TextButton(
                                                onPressed: () {
                                                  ratingController.addRating(
                                                      index,
                                                      widget.movieDetail.name
                                                          .toString(),
                                                      widget.movieDetail.slug
                                                          .toString(),
                                                      widget
                                                          .movieDetail.thumbUrl
                                                          .toString(),
                                                      widget
                                                          .movieDetail.posterUrl
                                                          .toString(),
                                                      context);
                                                  ratingController
                                                      .addHistoryActivity(
                                                          widget
                                                              .movieDetail.name
                                                              .toString(),
                                                          widget
                                                              .movieDetail.slug
                                                              .toString(),
                                                          'rating');
                                                  Navigator.pop(context);
                                                },
                                                style: TextButton.styleFrom(
                                                    minimumSize:
                                                        const Size(80, 60)),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      ratingIconList[index],
                                                      // Lấy icon từ danh sách
                                                      color: Colors.white70,
                                                      size: 30,
                                                    ),
                                                    Text(
                                                      ratingName,
                                                      // Lấy tên từ entry
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          )),
                                      child: Container(
                                        width: 100,
                                        alignment: Alignment.center,
                                        child: Column(
                                          children: [
                                            Icon(
                                              ratingIconList[1],
                                              color: Colors.white,
                                            ),
                                            const Text('Đánh giá',
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w400))
                                          ],
                                        ),
                                      ));
                                }
                                final document = documents[0];
                                final data =
                                    document.data() as Map<String, dynamic>;
                                final ratePoint = data['rate_point'] as int;
                                // Hiển thị thông tin đánh giá
                                // return Text('Đánh giá: $ratePoint', style: TextStyle(color: Colors.white),);
                                return CustomPopup(
                                    backgroundColor:
                                        const Color.fromRGBO(51, 51, 51, 1),
                                    contentPadding: const EdgeInsets.all(0),
                                    content: SizedBox(
                                        height: 70,
                                        width: 300,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          // Căn đều các phần tử
                                          children: ratingNameList
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            int index = entry
                                                .key; // Lấy chỉ số từ entry
                                            String ratingName = entry
                                                .value; // Lấy giá trị tên đánh giá từ entry

                                            return TextButton(
                                              onPressed: () {
                                                ratePoint == index
                                                    ? ratingController
                                                        .removeRating(
                                                            widget.movieDetail
                                                                .slug
                                                                .toString(),
                                                            document.id,
                                                            context)
                                                    : ratingController
                                                        .updateRating(
                                                            index,
                                                            document.id,
                                                            widget.movieDetail
                                                                .slug
                                                                .toString(),
                                                            context);
                                                Navigator.pop(context);
                                              },
                                              style: TextButton.styleFrom(
                                                  minimumSize:
                                                      const Size(80, 60)),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    ratingIconList[index],
                                                    // Lấy icon từ danh sách
                                                    color: ratePoint == index
                                                        ? Colors.white
                                                        : Colors.white70,
                                                    size: 30,
                                                  ),
                                                  Text(
                                                    ratingName,
                                                    // Lấy tên từ entry
                                                    style: TextStyle(
                                                      color: ratePoint == index
                                                          ? Colors.white
                                                          : Colors.white70,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        )),
                                    child: Container(
                                      width: 100,
                                      alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          Icon(
                                            ratingIconList[ratePoint],
                                            color: Colors.white,
                                          ),
                                          Text(ratingNameList[ratePoint],
                                              style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400))
                                        ],
                                      ),
                                    ));
                              })
                          : Container(
                              width: 100,
                              alignment: Alignment.center,
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const Common(),
                                        ));
                                  },
                                  child: const Column(
                                    children: [
                                      Icon(
                                        Icons.sentiment_satisfied,
                                        color: Colors.white,
                                      ),
                                      Text('Đánh giá',
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400))
                                    ],
                                  )),
                            )),
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.white54,
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: const Text('Danh sách tập',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ),
                GridView.builder(
                  controller: scrollController,
                  shrinkWrap: true,
                  itemCount: widget.episodesList.length,
                  itemBuilder: (context, index) => showEpisodesList(index),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.7),
                )
              ],
            ),
          ),
        ))
      ],
    );
  }

  showEpisodesList(int index) {
    return ElevatedButton(
        onPressed: () async {
          // Nếu đã đăng nhập thì lưu lại dữ liệu
          if (stateController.loginState.value) {
            await historyController.addEpisode(
              widget.movieDetail.name.toString(),
              widget.movieDetail.slug.toString(),
              widget.movieDetail.thumbUrl.toString(),
              widget.movieDetail.posterUrl.toString(),
              widget.episodesList[index].linkM3u8.toString(),
              widget.episodesList[index].name.toString(),
              index,
            );
          }
          Navigator.push(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(
                builder: (context) => LandscapePlayer(
                  currentIndex: index,
                  movieDetail: widget.movieDetail,
                  videoUrlList: widget.videoUrlList,
                  movieEpisodeNameList: widget.episodeNameList,
                ),
              ));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          widget.episodesList[index].name.toString(),
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ));
  }
}
