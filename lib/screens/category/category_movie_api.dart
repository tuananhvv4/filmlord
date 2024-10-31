import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:movies_app/model/data_movie.dart';
import 'package:movies_app/screens/movie/movie.dart';
import 'package:movies_app/utilites/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class CategoryMovieList extends StatefulWidget {
  final String category;
  final String title;

  const CategoryMovieList(
      {super.key, required this.category, required this.title});

  @override
  State<CategoryMovieList> createState() => _CategoryMovieListState();
}

class _CategoryMovieListState extends State<CategoryMovieList> {
  late String url;

  int page = 1;

  bool loadMoreState = true;

  List<Data> listMovieData = [];

  late final Future _future;

  final ScrollController scrollController = ScrollController();

  Future fetchData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonData;
    // log(widget.category);
    if (prefs.containsKey(widget.category)) {
      List<Data> jsonDataList =
          await Helper.getData(widget.category); // lấy dữ liệu đã cache
      listMovieData = jsonDataList; // chuyển từ String thành Map
    } else {
      var response = await http.get(Uri.parse(url));
      jsonData = jsonDecode(response.body);
      for (var item in jsonData['data']) {
        Data itemData = Data.fromJson(item);
        listMovieData.add(itemData);
        Helper.saveData(
            widget.category, listMovieData); // lưu dữ liệu vào bộ nhớ
      }
    }
  }

  Future loadMore() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('${widget.category}-currentPage')) {
      int? currentPage = prefs.getInt(('${widget.category}-currentPage'))!;
      page = currentPage;
    }
    setState(() {
      page += 1;
      url =
          'https://nguyenanh.site/api/movie_app/category-movie.php?type=${widget.category}&page=$page';
    });
    prefs.setInt(
        '${widget.category}-currentPage', page); // lưu lại trang hiện tại
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);
    if (mounted) {
      setState(() {
        for (var item in jsonData['data']) {
          Data itemData = Data.fromJson(item);
          listMovieData.add(itemData);
        }
        Helper.saveData(widget.category, listMovieData);

        if (jsonData['total'] < 10) {
          loadMoreState = false;
        }
      });
    }
  }

  @override
  void initState() {
    url =
        'https://nguyenanh.site/api/movie_app/category-movie.php?type=${widget.category}&page=$page';
    _future = fetchData();
    scrollController.addListener(
      () {
        if (scrollController.position.maxScrollExtent ==
            scrollController.offset) {
          loadMore();
        }
      },
    );
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
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              controller: loadMoreState ? scrollController : null,
              itemCount: listMovieData.length + 1,
              itemBuilder: (context, index) {
                if (index < listMovieData.length) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  MovieScreen(
                            slug: listMovieData[index].slug.toString(),
                          ),
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
                                    listMovieData[index].thumbUrl.toString()),
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
                              listMovieData[index].name.toString(),
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
                  );
                } else {
                  return loadMoreState
                      ? Padding(
                          padding: const EdgeInsets.only(left: 180, right: 180),
                          child: LoadingAnimationWidget.waveDots(
                            color: Colors.white,
                            size: 30,
                          ),
                        )
                      : const SizedBox();
                }
              },
            );
          } else {
            return Center(
                child: LoadingAnimationWidget.fourRotatingDots(
                    color: Colors.white, size: 30));
          }
        },
      ),
    );
  }
}
