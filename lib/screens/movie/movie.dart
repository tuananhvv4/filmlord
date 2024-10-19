import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:movies_app/controller/fireBase/favorite_firebase_controller.dart';
import 'package:movies_app/screens/movie/movie_comment.dart';
import 'package:movies_app/screens/movie/movie_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../model/detail_movie.dart';



class MovieScreen extends StatefulWidget {

  final String slug;
  const MovieScreen({super.key, required this.slug});


  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen>
    with TickerProviderStateMixin {


  final videourl = 'https://www.youtube.com/watch?v=YMx8Bbev6T4&t=3s';


  // controller

  late final TabController _tabController;
  
  final favoriteController = FavoriteFirebaseController();


  bool isLoading = true;

  late String trailerUrlEmbed;


  Movie movieDetail = Movie();
  List<ServerData> episodesList = [];
  List<String> categoriesList = [];
  List<String> episodeNameList = [];
  List<String> videoUrlList = [];


  Future<void> setCacheData(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(widget.slug, value); // Xóa tất cả dữ liệu đã lưu
  }

  Future<String> getCacheData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(widget.slug);
    return data!;
  }

  Future getMovieDetail() async {
    if (isLoading) {
      isLoading = false;

      try{

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        dynamic jsonData;
        if(prefs.containsKey(widget.slug)){
          var jsonString = await getCacheData(); // lấy dữ liệu từ String
          jsonData = jsonDecode(jsonString); // chuyển từ String thành Map
        }else{
          var response =
          await http.get(Uri.parse('https://phimapi.com/phim/${widget.slug}'));
          jsonData = jsonDecode(response.body); // sau khi decode => Map
          setCacheData(jsonEncode(jsonData)); // chuyển Map => String và lưu lại
        }

        Movie movie = Movie.fromJson(jsonData['movie']);
        movieDetail = movie;
        for (var item in jsonData['episodes'][0]['server_data']) {
          ServerData episodes = ServerData.fromJson(item);
          episodesList.add(episodes);
        }

        for(var i = 0 ; i < episodesList.length ; i++){
          episodeNameList.add(episodesList[i].name.toString());
          videoUrlList.add(episodesList[i].linkM3u8.toString());
        }

        for (var item in jsonData['movie']['category']) {
          Category category = Category.fromJson(item);
          categoriesList.add(category.name.toString());
        }
      }catch(e){
        log(e.toString());
      }
    }
  }


  // YoutubePlayerController _controller = YoutubePlayerController(
  //   initialVideoId: 'GQyWIur03aw',
  //   flags: YoutubePlayerFlags(
  //     autoPlay: false,
  //     mute: true,
  //   ),
  // );

  @override
  void initState() {

    // final videoID = YoutubePlayer.convertUrlToId(videourl);
    // _youtubeController = YoutubePlayerController(
    //     initialVideoId: videoID!,
    //     flags: YoutubePlayerFlags(
    //       autoPlay: false
    //     )
    // );
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        // actions: [
        //   IconButton(onPressed: () {
        //     favoriteController.addRecommend(movieDetail.name.toString(), movieDetail.slug.toString(), movieDetail.thumbUrl.toString(), movieDetail.posterUrl.toString());
        //   }, icon: Icon(Icons.add,
        //   color: Colors.white,))
        // ],
      ),
      body: FutureBuilder(
          future: getMovieDetail(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.done){
              return Column(
                children: <Widget>[
                  SizedBox(
                    // margin: EdgeInsets.only(top:30),
                    height: 230,
                    child: movieDetail.trailerUrl.toString().isNotEmpty

                        ? WebViewWidget(
                        controller: WebViewController()
                          ..setJavaScriptMode(JavaScriptMode.unrestricted)
                          ..loadRequest(Uri.parse(
                              'https://www.youtube.com/embed/${RegExp(r"v=([^&]*)").firstMatch(movieDetail.trailerUrl.toString())?.group(1) ?? ""}?autoplay=1')))
                        : CachedNetworkImage(
                      imageUrl: movieDetail.thumbUrl.toString(),
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey,
                        highlightColor: Colors.white,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                      const Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 10,),
                  TabBar(
                    controller: _tabController,
                    tabs: const <Widget>[
                      Tab(text: 'Thông tin'),
                      Tab(text: 'Bình luận'),
                    ],
                    dividerHeight: 0,
                    labelColor: Colors.white,
                    indicator: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(5)
                    ),
                    unselectedLabelColor: Colors.white54,
                    indicatorSize: TabBarIndicatorSize.tab,
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        MovieDetail(movieDetail: movieDetail, episodesList: episodesList, categoriesList: categoriesList, episodeNameList: episodeNameList, videoUrlList: videoUrlList),
                        MovieComment(movieDetail: movieDetail,)
                      ],
                    ),
                  ),
                ],
              );
            }else{
              return Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                      color: Colors.white, size: 30));
            }
          },),
    );
  }
}