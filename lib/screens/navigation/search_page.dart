import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:movies_app/model/search_movie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../movie/movie.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  // Thời gian điểm ngược
  Timer? _debounce;

  // controller
  final controller = ScrollController();
  final searchController = TextEditingController();
  final scrollController = ScrollController();

  int startPosition = 0;
  int endPosition = 10;
  int total = 0;

  late String urlSearchMovies;
  String searchKeyword = '';
  bool isSearch = false;
  bool isLoadingMore = false;

  List<String> _searchHistory = [];

  late Future<void> _futureNewMovies = fetchSearchMoviesData();

  List<SearchMovieItem> searchMovieItemsList =[];
  List<SearchMovieItem> tempList =[];

  // hàm tải dữ liệu khi ấn tìm kiếm lần đầu
  Future fetchSearchMoviesData() async {

    searchMovieItemsList = [];

    if(searchKeyword != ''){
      var searchMoviesResponse = await http.get(Uri.parse(urlSearchMovies));
      var searchMoviesJsonData = jsonDecode(searchMoviesResponse.body);
      total = searchMoviesJsonData['total'];

      if(total != 0){
        for (var item in searchMoviesJsonData['data']) {
          SearchMovieItem film = SearchMovieItem.fromJson(item);
          searchMovieItemsList.add(film);
        }
      }
    }
  }

  // hàm xử lý tải thêm dữ liệu khi cuộn
  Future<void> loadMore() async {
    if (controller.position.maxScrollExtent == controller.offset) {

      setState(() {
        isLoadingMore = true ;
      });
      setState(() {
        startPosition += 10;
        endPosition += 10;
        urlSearchMovies = 'https://nguyenanh.site/api/movie_app/search-movie.php?keyword=$searchKeyword&start=$startPosition&end=$endPosition';
      });
      var searchMoviesResponse = await http.get(Uri.parse(urlSearchMovies));
      var searchMoviesJsonData = jsonDecode(searchMoviesResponse.body);

      for (var item in searchMoviesJsonData['data']) {
        SearchMovieItem film = SearchMovieItem.fromJson(item);
        searchMovieItemsList.add(film);
      }

      setState(() {
        searchMovieItemsList.addAll(tempList);
      });

      // Future.delayed(const Duration(seconds: 5));
      // setState(() {
      //   isLoadingMore = false;
      // });
    }
  }


  // hàm tìm kiếm
  void searchProcess( String value ){
    // if (_debounce?.isActive ?? false) _debounce?.cancel();
    // _debounce = Timer(const Duration(milliseconds: 1500), () {
    //   if(value.isNotEmpty && value.trim() != searchKeyword){
    //     _saveSearchHistory(value.trim());
    //     setState(() {
    //       startPosition = 0;
    //       endPosition = 10;
    //       isSearch = true;
    //       searchKeyword = value.trim();
    //       urlSearchMovies = 'https://nguyenanh.site/api/movie_app/search-movie.php?keyword=$searchKeyword&start=$startPosition&end=$endPosition';
    //       _futureNewMovies = fetchSearchMoviesData();
    //     });
    //   }
    // });

    try{
      if(value.isNotEmpty && value.trim() != searchKeyword){
        _saveSearchHistory(value.trim());
        setState(() {
          startPosition = 0;
          endPosition = 10;
          isSearch = true;
          searchKeyword = value.trim();
          urlSearchMovies = 'https://nguyenanh.site/api/movie_app/search-movie.php?keyword=$searchKeyword&start=$startPosition&end=$endPosition';
          _futureNewMovies = fetchSearchMoviesData();
        });
      }
    }catch(e){
      log(e.toString());
    }
  }

  // Hàm lưu lịch sử tìm kiếm
  void _saveSearchHistory(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _searchHistory.add(query);
    _searchHistory = _searchHistory.toSet().toList(); // Xóa trùng lặp
    if (_searchHistory.length > 4) {
      _searchHistory.removeAt(0); // Giới hạn chỉ giữ 4 từ khóa
    }
    await prefs.setStringList('searchHistory', _searchHistory);
  }

  // Hàm tải lịch sử tìm kiếm
  void _loadSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? []; // nếu không có thì để trống
    });
  }


  // khởi tạo 1 số biến và controller
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futureNewMovies = fetchSearchMoviesData();
    urlSearchMovies = 'https://nguyenanh.site/api/movie_app/search-movie.php?keyword=$searchKeyword&start=$startPosition&end=$endPosition';
    controller.addListener(() {
      loadMore();
    },);
    searchController.addListener(() {
      if(searchController.text.isEmpty){
        setState(() {
          isSearch = false;
        });
      }
    },);
    _loadSearchHistory();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _debounce?.cancel();
    controller.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(
              color: Colors.white
          ),
          title: Container(
            height: 50,
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: TextField(
              autofocus: true,
              onSubmitted: searchProcess,
              style: const TextStyle(
                  color: Colors.white
              ),
              controller: searchController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 5),
                  filled: true,
                  fillColor: Colors.white24,

                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none
                  ),
                  hintText: 'Nhập tên phim,..',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search),
                  prefixIconColor: Colors.white,
                  suffixIcon: searchController.text.isNotEmpty ? IconButton(
                      onPressed: searchController.text.isNotEmpty ? () {
                        searchController.clear();
                        searchKeyword = '';
                      } : null,
                      icon: const Icon(Icons.clear,color: Colors.white,)
                  ) : null
              ),
            ),
          ),
        ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          height: double.maxFinite,
          child: isSearch
              ? FutureBuilder(
            future: _futureNewMovies,
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.done){
                if(searchMovieItemsList.isEmpty){
                  return Align(
                    alignment: AlignmentDirectional.topCenter,
                    child: Text('Có $total kết quả.',
                      style: const TextStyle(
                          color: Colors.white
                      ),),
                  );
                }else{
                  return Column(
                    children: [
                      Text('Có $total kết quả.',
                      style: const TextStyle(
                        color: Colors.white
                      ),),
                      Expanded(
                        child: ListView.builder(
                          controller: controller,
                          itemCount: searchMovieItemsList.length + 1,
                          itemBuilder: (context, index) {
                            if(index < searchMovieItemsList.length){
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                          MovieScreen(
                                            slug: searchMovieItemsList[index]
                                                .slug
                                                .toString(),
                                          ),
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
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      top: 5, bottom: 5),
                                  decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(
                                            right: 5),
                                        height: 100,
                                        width: 150,
                                        clipBehavior: Clip.hardEdge,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
                                        child: CachedNetworkImage(
                                          imageUrl: 'https://www.kkphim.vip/${searchMovieItemsList[index]
                                              .thumbUrl}',
                                          placeholder: (context, url) =>
                                              Shimmer.fromColors(
                                                baseColor: Colors.grey,
                                                highlightColor: Colors
                                                    .white,
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    color: Colors.black26,
                                                  ),
                                                ),
                                              ),
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) =>const Image(image: AssetImage('assets/images/no-image-landscape.png')),),
                                      ),
                                      Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5, left: 5),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(
                                                  'Tên: ${searchMovieItemsList[index]
                                                      .name.toString()}',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      overflow: TextOverflow
                                                          .ellipsis
                                                  ),),
                                                // searchMovieItemsList[index]
                                                //     .episodeCurrent
                                                //     .toString() == 'Full'
                                                //     ?
                                                // const Text('Loại: Phim lẻ',
                                                //   style: TextStyle(
                                                //       color: Colors.white,
                                                //       fontSize: 12
                                                //   ),) :
                                                // Column(
                                                //   crossAxisAlignment: CrossAxisAlignment
                                                //       .start,
                                                //   children: [
                                                //     const Text(
                                                //       'Loại: Phim bộ',
                                                //       style: TextStyle(
                                                //           color: Colors
                                                //               .white,
                                                //           fontSize: 12
                                                //       ),),
                                                //     Text(
                                                //       'Tập mới nhất: ${searchMovieItemsList[index]
                                                //           .episodeCurrent
                                                //           .toString()}',
                                                //       style: const TextStyle(
                                                //           color: Colors
                                                //               .white,
                                                //           fontSize: 12
                                                //       ),),
                                                //
                                                //   ],
                                                // ),
                                                Text(
                                                  'Thời lượng: ${searchMovieItemsList[index]
                                                      .time.toString()}',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      overflow: TextOverflow
                                                          .ellipsis
                                                  ),),
                                                Text(
                                                  'Năm: ${searchMovieItemsList[index]
                                                      .year.toString()}',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      overflow: TextOverflow
                                                          .ellipsis
                                                  ),),
                                              ],
                                            ),
                                          ))
                                    ],
                                  ),
                                ),
                              );
                            }else{
                              if(endPosition > total){
                                return Container(height: 10,);
                              }else{
                                return isLoadingMore? Container(
                                  padding: const EdgeInsets.only(left: 165,right: 165),
                                  child: LoadingAnimationWidget.waveDots(
                                    color: Colors.white,
                                    size:30,),
                                ) : Container(height: 10,);
                              }
                            }
                          },),
                      ),
                    ],
                  );
                }
              }
              else{
                return  Center(
                    child: LoadingAnimationWidget.fourRotatingDots(color: Colors.white, size: 30)
                );
              }
            },)
              : Column(
                children: [
                  Center(
                    child: ListView.builder(
                      reverse: true,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _searchHistory.length,
                      itemBuilder: (context, index) {
                        return MaterialButton(
                            onPressed: () {
                                  // Xử lý khi người dùng chọn từ khóa đã lưu
                                  // log("Selected: ${_searchHistory[index]}");
                                  searchProcess(_searchHistory[index]);
                                  searchController.text = _searchHistory[index];
                            },
                        child: SizedBox(
                          height: 55,
                          child: Row(
                            children: [
                              const Icon(Icons.history,color: Colors.white,),
                              Expanded(child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 5, 0),
                                child: Text(_searchHistory[index],
                                maxLines: 1,
                                style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  color: Colors.white,

                                ),),
                              )),
                              const Icon(Icons.north_west,color: Colors.white,)
                            ],
                          ),
                        ),);
                        // return ListTile(
                        //   title: Text(_searchHistory[index]),
                        //   onTap: () {
                        //     // Xử lý khi người dùng chọn từ khóa đã lưu
                        //     log("Selected: ${_searchHistory[index]}");
                        //     searchProcess(_searchHistory[index]);
                        //     searchController.text = _searchHistory[index];
                        //
                        //   },
                        // );
                      },
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('recommendMovies')
                          .snapshots()
                      ,
                      builder: (context, snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return const SizedBox();
                        }
                        // lấy dữ liệu và random
                        final List<DocumentSnapshot> documents = snapshot.data!.docs;
                        documents.shuffle();

                        return SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: [
                              const Text('Chương trình truyền hình và phim được đề xuất!',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600
                                ),),
                              const SizedBox(
                                height: 5,
                              ),
                              GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,crossAxisSpacing: 10,mainAxisSpacing: 10,childAspectRatio: 0.7),
                                controller: scrollController,
                                shrinkWrap: true,
                                itemCount: 30,
                                itemBuilder: (context, index) {
                                  var item = documents[index];

                                  return Container(
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                                MovieScreen(
                                                  slug: item['slug'],
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
                                      child: CachedNetworkImage(
                                        imageUrl: item['poster_url'],
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
                                    ),
                                  );
                                },),
                            ],
                          ),
                        );

                      },),
                  ),
                ],
              ),
        ),
      )

    );
  }
}
