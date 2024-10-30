import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:movies_app/api/api_services.dart';
import 'package:movies_app/controller/fireBase/history_firebase_controller.dart';
import 'package:movies_app/model/data_movie.dart';
import 'package:movies_app/screens/navigation/search_page.dart';
import 'package:movies_app/screens/user/common.dart';

import 'package:movies_app/controller/GetX/state_controller.dart';
import 'package:movies_app/widget/movie_list.dart';
import 'package:shimmer/shimmer.dart';

import '../../controller/fireBase/favorite_firebase_controller.dart';
import '../../model/detail_movie.dart';
import '../category/category_movie_api.dart';
import '../category/category_movie_firebase.dart';
import '../movie/movie.dart';
import '../movie/videoPlayer/flick_full_screen_custom.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoaded = false;

  bool playButtonState = true;

  //getX Controller
  final stateController = Get.find<StateManager>();

  // Firebase
  final favoriteController = FavoriteFirebaseController();
  final historyController = HistoryFirebaseController();

  // Future
  late Future<void> _futureNewMovies;

  // List Data
  List<Data> newMoviesList = [];

  Future fetchNewMoviesData() async {
    if (stateController.isLoadData.value == false) {
      newMoviesList = await compute(ApiServices.fetchNewMoviesData, 'phim-moi');
      isLoaded = true;
    }
  }

  // Hàm xử lý nút xem ngay
  Future playNow(String slug) async {
    setState(() {
      playButtonState = !playButtonState;
    });

    Future.delayed(
      const Duration(seconds: 2),
      () {
        setState(() {
          playButtonState = !playButtonState;
        });
      },
    );

    stateController.disableAutoPlay();
    List<ServerData> episodesList = [];
    Movie movieDetail = Movie();
    List<String> episodeNameList = [];
    List<String> videoUrlList = [];
    var response = await http.get(Uri.parse('https://phimapi.com/phim/$slug'));
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      Movie movie = Movie.fromJson(jsonData['movie']);
      movieDetail = movie;
      // print(jsonData['episodes'][0]['server_data']);
      for (var item in jsonData['episodes'][0]['server_data']) {
        ServerData episodes = ServerData.fromJson(item);
        episodesList.add(episodes);
      }

      for (var i = 0; i < episodesList.length; i++) {
        episodeNameList.add(episodesList[i].name.toString());
        videoUrlList.add(episodesList[i].linkM3u8.toString());
      }
    }
    if (stateController.loginState.value) {
      await historyController.addEpisode(
          movieDetail.name.toString(),
          movieDetail.slug.toString(),
          movieDetail.thumbUrl.toString(),
          movieDetail.posterUrl.toString(),
          videoUrlList[0],
          episodeNameList[0],
          0);
    }
    Get.to(LandscapePlayer(
      videoUrlList: videoUrlList,
      movieDetail: movieDetail,
      movieEpisodeNameList: episodeNameList,
      currentIndex: 0,
    ));
  }

  @override
  void initState() {
    super.initState();
    _futureNewMovies = fetchNewMoviesData();
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
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const SearchPage(),
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
                  icon: const Icon(
                    Iconsax.search_normal_1,
                    color: Colors.white,
                  )),
            )
          ],
        ),
        backgroundColor: Colors.black,
        body: RefreshIndicator(
          backgroundColor: Colors.white,
          color: Colors.black,
          onRefresh: () async {
            setState(() {
              _futureNewMovies = fetchNewMoviesData();
            });
            stateController.initCarouselIndex();
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                FutureBuilder(
                  future: _futureNewMovies,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.60,
                        width: MediaQuery.of(context).size.width,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Hiển thị ảnh nền
                            isLoaded
                                ? Obx(
                                    () => CachedNetworkImage(
                                      imageUrl: newMoviesList[stateController
                                              .currentCarouselIndex.value]
                                          .posterUrl
                                          .toString(),
                                      placeholder: (context, url) =>
                                          Shimmer.fromColors(
                                        baseColor: Colors.black26,
                                        highlightColor: Colors.white,
                                        child: Container(
                                          color: Colors.black12,
                                        ),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const SizedBox(),
                            // Lớp màu phủ trên ảnh
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                      Colors.black.withOpacity(1.0),
                                      Colors.black.withOpacity(0.9),
                                      Colors.black.withOpacity(0.65),
                                      Colors.black.withOpacity(0.65),
                                      Colors.black.withOpacity(0.65),
                                      Colors.black.withOpacity(0.65),
                                      Colors.black.withOpacity(0.65),
                                      Colors.black.withOpacity(0.65),
                                    ])),
                              ),
                            ),
                            // Carousel
                            Positioned(
                              top: 50,
                              bottom: 60,
                              // height: MediaQuery.of(context).size.height * 0.7,
                              width: MediaQuery.of(context).size.width,
                              child: CarouselSlider(
                                options: CarouselOptions(
                                  height: 320.0,
                                  // aspectRatio: 16 / 9,
                                  viewportFraction: 0.60,
                                  autoPlay: stateController.autoPlayState.value,
                                  pauseAutoPlayOnTouch: true,
                                  onPageChanged: (index, reason) {
                                    stateController.updateCarouselIndex(index);
                                  },
                                ),
                                carouselController: CarouselSliderController(),
                                items: newMoviesList.map((movie) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context,
                                                        animation,
                                                        secondaryAnimation) =>
                                                    MovieScreen(
                                                  slug: movie.slug.toString(),
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
                                          child: Obx(
                                            () => AnimatedScale(
                                              scale: stateController
                                                          .currentCarouselIndex
                                                          .value ==
                                                      newMoviesList
                                                          .indexOf(movie)
                                                  ? 1.15
                                                  : 1.0,
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 15.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        height: 320,
                                                        width: double.infinity,
                                                        // margin: const EdgeInsets.only(top: 30),
                                                        clipBehavior:
                                                            Clip.hardEdge,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: movie
                                                              .posterUrl
                                                              .toString(),
                                                          placeholder: (context,
                                                                  url) =>
                                                              Shimmer
                                                                  .fromColors(
                                                            baseColor:
                                                                Colors.black26,
                                                            highlightColor:
                                                                Colors.white,
                                                            child: Container(
                                                              color: Colors
                                                                  .black12,
                                                            ),
                                                          ),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      // const SizedBox(height: 20),
                                                    ],
                                                  )),
                                            ),
                                          ));
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                            // nút xem ngay và thêm vào danh sách
                            Positioned(
                                bottom: 5,
                                left: 15,
                                right: 15,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: ElevatedButton(
                                          onPressed: playButtonState
                                              ? () {
                                                  playNow(newMoviesList[
                                                          stateController
                                                              .currentCarouselIndex
                                                              .value]
                                                      .slug
                                                      .toString());
                                                }
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              alignment: Alignment.centerRight,
                                              maximumSize: const Size(70, 50),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3)),
                                              padding: const EdgeInsets.all(0)),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.play_arrow,
                                                color: Colors.black,
                                              ),
                                              Text(
                                                'Xem ngay',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 17),
                                              )
                                            ],
                                          ),
                                        ),
                                      )),
                                      Obx(
                                        () => stateController.loginState.value
                                            // đã đăng nhập
                                            ? StreamBuilder<QuerySnapshot>(
                                                stream: favoriteController
                                                    .isFavoriteQuery(newMoviesList[
                                                            stateController
                                                                .currentCarouselIndex
                                                                .value]
                                                        .slug
                                                        .toString()),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    final documents =
                                                        snapshot.data!.docs;
                                                    bool hasMovie =
                                                        documents.isNotEmpty;
                                                    //Có dữ liệu

                                                    return Expanded(
                                                        child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 10),
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          if (hasMovie) {
                                                            favoriteController
                                                                .removeFavoriteMovie(
                                                                    documents
                                                                        .first
                                                                        .id);
                                                          } else {
                                                            favoriteController.addFavoriteMovie(
                                                                newMoviesList[stateController
                                                                        .currentCarouselIndex
                                                                        .value]
                                                                    .name
                                                                    .toString(),
                                                                newMoviesList[stateController
                                                                        .currentCarouselIndex
                                                                        .value]
                                                                    .slug
                                                                    .toString(),
                                                                newMoviesList[stateController
                                                                        .currentCarouselIndex
                                                                        .value]
                                                                    .thumbUrl
                                                                    .toString(),
                                                                newMoviesList[stateController
                                                                        .currentCarouselIndex
                                                                        .value]
                                                                    .posterUrl
                                                                    .toString());
                                                          }
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  const SnackBar(
                                                            content: Text(
                                                                'Thao tác thành công!'),
                                                            duration: Duration(
                                                                seconds: 1),
                                                          ));
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.white38,
                                                          alignment: Alignment
                                                              .centerRight,
                                                          maximumSize:
                                                              const Size(
                                                                  70, 50),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3)),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              hasMovie
                                                                  ? Icons.check
                                                                  : Icons.add,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            const Text(
                                                              'Danh sách',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 17),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ));
                                                  } else if (snapshot
                                                      .hasError) {
                                                    // Có lỗi
                                                    return Text(
                                                        'Error: ${snapshot.error}');
                                                  } else {
                                                    // Mặc định
                                                    return Expanded(
                                                        child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 10),
                                                      child: const Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.add,
                                                            color: Colors.white,
                                                          ),
                                                          Text(
                                                            'Danh sách',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 17),
                                                          )
                                                        ],
                                                      ),
                                                    ));
                                                  }
                                                },
                                              )
                                            // chưa đăng nhập
                                            : Expanded(
                                                child: Container(
                                                margin: const EdgeInsets.only(
                                                    left: 10, right: 10),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const Common(),
                                                        ));
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white38,
                                                    alignment:
                                                        Alignment.centerRight,
                                                    maximumSize:
                                                        const Size(70, 50),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        3)),
                                                    padding:
                                                        const EdgeInsets.all(0),
                                                  ),
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                      ),
                                                      Text(
                                                        'Danh sách',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 17),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )),
                                      )
                                    ],
                                  ),
                                )),

                            // nút thể loại
                            Positioned(
                                left: 5,
                                top: 10,
                                height: 30,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: SizedBox(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        showListCategory();
                                      },
                                      style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.only(
                                              left: 15, right: 5),
                                          maximumSize: const Size(100, 40),
                                          side: const BorderSide(
                                              color: Colors.white, width: 1)),
                                      child: const Row(
                                        children: [
                                          Text(
                                            'Thể loại',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white,
                                                fontSize: 14),
                                          ),
                                          Icon(
                                            Icons.keyboard_arrow_down,
                                            size: 25,
                                            color: Colors.white,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      );
                    } else {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey,
                        highlightColor: Colors.white,
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.black26,
                          ),
                          height: 500,
                        ),
                      );
                    }
                  },
                ),
                // Tiếp tục xem
                Obx(
                  () => stateController.loginState.value
                      ? StreamBuilder<QuerySnapshot>(
                          stream: historyController.historyQuery(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Container();
                            } else {
                              QuerySnapshot querySnapshot = snapshot.data!;
                              int count = querySnapshot.size;
                              return Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(
                                        10, 10, 5, 10),
                                    height: 35,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'TIẾP TỤC XEM',
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
                                                  pageBuilder: (context,
                                                          animation,
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
                                          margin:
                                              const EdgeInsets.only(left: 10),
                                          width: 130,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(5)),
                                              color: Colors.grey.shade100),
                                          alignment: Alignment.centerLeft,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder: (context,
                                                          animation,
                                                          secondaryAnimation) =>
                                                      MovieScreen(
                                                    slug: documentSnapshot[
                                                        'slug'],
                                                  ),
                                                  transitionsBuilder: (context,
                                                      animation,
                                                      secondaryAnimation,
                                                      child) {
                                                    const begin =
                                                        Offset(1.0, 0.0);
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
                                                imageUrl: documentSnapshot[
                                                    'poster_url'],
                                                placeholder: (context, url) =>
                                                    Shimmer.fromColors(
                                                  baseColor: Colors.grey,
                                                  highlightColor: Colors.white,
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
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
                        )
                      : const SizedBox(),
                ),

                //Phim mới
                MovieListWidget(
                    category: 'phim-moi', title: 'PHIM MỚI CẬP NHẬT'),
                //Phim lẻ
                MovieListWidget(category: 'phim-le', title: 'PHIM LẺ'),
                //Phim bộ
                MovieListWidget(category: 'phim-bo', title: 'PHIM BỘ'),
                //Phim hoạt hình
                MovieListWidget(category: 'hoat-hinh', title: 'HOẠT HÌNH'),
                //TV show
                MovieListWidget(category: 'tv-shows', title: 'TV SHOW'),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ));
  }

  void showListCategory() {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          color: const Color.fromRGBO(0, 0, 0, 0.75),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 50, bottom: 15),
                  alignment: Alignment.center,
                  child: const Text(
                    'Danh Sách Thể loại',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 22),
                  ),
                ),
                Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    padding: const EdgeInsets.only(left: 100, right: 100),
                    child: ListView.builder(
                      itemCount: 20,
                      itemBuilder: (context, index) {
                        return MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        CategoryMovieList(
                                  category: ApiServices.slugCase[index],
                                  title: ApiServices.upperCase[index],
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
                          child: Text(
                            ApiServices.originalCase[index],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                                fontSize: 18),
                          ),
                        );
                      },
                    )),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 65,
                    ))
              ],
            ),
          ),
        );
      },
    );
  }
}
