
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:movies_app/model/detail_movie.dart';
import 'package:video_player/video_player.dart';


import '../../../controller/GetX/state_controller.dart';
import '../../../controller/fireBase/history_firebase_controller.dart';
import 'landscape_player_controls.dart';

class LandscapePlayer extends StatefulWidget {


  final int currentIndex; // vị trí hiện tại
  final Movie movieDetail; // thông tin phim
  final List<String> videoUrlList; // danh sách URL Video
  final List<String> movieEpisodeNameList; // danh sách tên tập
  const LandscapePlayer({
    super.key,
    required this.videoUrlList,
    required this.movieDetail,
    required this.movieEpisodeNameList,
    required this.currentIndex,
  });

  @override
  _LandscapePlayerState createState() => _LandscapePlayerState();
}

class _LandscapePlayerState extends State<LandscapePlayer> {
  late FlickManager flickManager;

  //GetX Controller
  final stateController = Get.find<StateManager>();

  // firebase controller
  final historyController = HistoryFirebaseController();

  int currentEpisodeIndex = 0;

  // chuyển tập phim
  void _changeEpisode(int newIndex) async {

    currentEpisodeIndex = newIndex;
    // lưu lại thông tin tập phim sau khi chuyển
    if(stateController.loginState.value){
      try{
        await  historyController.addEpisode(
            widget.movieDetail.name.toString(),
            widget.movieDetail.slug.toString(),
            widget.movieDetail.thumbUrl.toString(),
            widget.movieDetail.posterUrl.toString(),
            widget.videoUrlList[currentEpisodeIndex].toString(),
            widget.movieEpisodeNameList[newIndex].toString(),
            newIndex
        );
      }catch(e){
        print(e);
      }
    }

    setState(() {
      flickManager.handleChangeVideo(
          VideoPlayerController.network(widget.videoUrlList[currentEpisodeIndex]));
    });
  }
  



  @override
  void initState() {
    currentEpisodeIndex = widget.currentIndex;
    super.initState();
    flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.networkUrl(
            Uri.parse(widget.videoUrlList[widget.currentIndex])));

  }


  @override
  void dispose() {

    if(stateController.loginState.value){
      historyController.updateWatchingTime(widget.movieDetail.slug.toString(),
          widget.movieEpisodeNameList[currentEpisodeIndex], flickManager.flickVideoManager!.videoPlayerValue!.position.inMinutes.toInt());
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp]);
    flickManager.dispose();
    stateController.enableAutoPlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlickVideoPlayer(
        flickManager: flickManager,
        preferredDeviceOrientation: const [
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft
        ],
        systemUIOverlay: const [],
        flickVideoWithControls: FlickVideoWithControls(
          videoFit: BoxFit.contain,
          controls: LandscapePlayerControls( movieDetail: widget.movieDetail,
            movieEpisodeName: widget.movieEpisodeNameList,
            initialEpisodeIndex: currentEpisodeIndex,
            episodesLength: widget.videoUrlList.length,
            callbacktoParent: _changeEpisode,
          ),
        ),
      ),
    );
  }
}