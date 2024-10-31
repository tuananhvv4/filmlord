import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:movies_app/screens/movie/videoPlayer/flick_seek_video_action_custom.dart';
import 'package:movies_app/screens/movie/videoPlayer/flick_sound_toggle_custom.dart';
import 'package:movies_app/screens/movie/videoPlayer/play_toggle.dart';
import 'package:provider/provider.dart';

import '../../../controller/GetX/state_controller.dart';
import '../../../controller/GetX/movie_controller.dart';
import '../../../api/fireBase/history_firebase_controller.dart';
import '../../../model/detail_movie.dart';

class LandscapePlayerControls extends StatefulWidget {
  final Function(int) callbacktoParent;
  final int initialEpisodeIndex; // vị trí hiện tại
  final Movie movieDetail; // thông tin phim
  final int episodesLength; // độ dài của danh sách phim
  final List<String> movieEpisodeName; // danh sách tên tập
  const LandscapePlayerControls({
    super.key,
    this.iconSize = 30,
    this.fontSize = 12,
    required this.movieDetail,
    required this.movieEpisodeName,
    required this.initialEpisodeIndex,
    required this.callbacktoParent,
    required this.episodesLength,
  });
  final double iconSize;
  final double fontSize;

  @override
  State<LandscapePlayerControls> createState() =>
      _LandscapePlayerControlsState();
}

class _LandscapePlayerControlsState extends State<LandscapePlayerControls> {
  //GetX Controller
  final stateController = Get.find<StateManager>();
  final movieController = Get.find<MovieController>();

  // Firebase Controller
  final historyController = HistoryFirebaseController();

  bool isLoad = false;
  int currentEpisodeIndex = 0;
  double playBackSpeed = 1.0;
  final List<double> playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  @override
  void initState() {
    super.initState();
    currentEpisodeIndex =
        widget.initialEpisodeIndex; // Initialize with the passed index
  }

  void goToNextEpisode() async {
    if (currentEpisodeIndex < widget.episodesLength - 1) {
      movieController.initSeekTime();
      widget.callbacktoParent(currentEpisodeIndex + 1);
    }
  }

  void goToPreviousEpisode() async {
    if (currentEpisodeIndex > 0) {
      movieController.initSeekTime();
      widget.callbacktoParent(currentEpisodeIndex - 1);
    }
  }

  void goToEpisode(int newEpisode) async {
    movieController.initSeekTime();
    widget.callbacktoParent(newEpisode);
  }

  openEpisodeDialog() {
    // Tạo ScrollController
    ScrollController _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Tự động cuộn đến vị trí của indexEpisode
      _scrollController.jumpTo(
        (widget.initialEpisodeIndex / 4) *
            70, // Chia theo số cột của GridView (4 cột ở đây)
      );
    });

    showDialog(
      context: context,
      builder: (context) {
        // cần chỉnh lại màu khi ở light mode
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(30, 30, 30, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Bo tròn góc
            side: const BorderSide(
                color: Colors.white24, width: 2), // Màu và độ dày của viền
          ),
          title: const Text(
            'Danh sách tập',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.5,
            child: GridView.builder(
              controller: _scrollController,
              itemCount: widget.episodesLength,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, childAspectRatio: 1.5),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: widget.initialEpisodeIndex == index
                        ? Colors.white54
                        : Colors.white12,
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      goToEpisode(index);
                      Navigator.pop(context);
                    },
                    child: Text(
                      widget.movieEpisodeName[index],
                      maxLines: 1,
                      style: const TextStyle(
                          color: Colors.white, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    movieController.initSeekTime();
    // movieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlickControlManager controlManager =
        Provider.of<FlickControlManager>(context);
    FlickVideoManager videoManager = Provider.of<FlickVideoManager>(context);

    if (isLoad == false) {
      controlManager.seekTo(Duration(minutes: movieController.getSeekTime()));
      isLoad = true;
    }

    return Stack(
      children: <Widget>[
        const FlickShowControlsAction(
          child: FlickSeekVideoActionCustom(
            child: Center(
              child: FlickVideoBuffer(
                child: FlickAutoHideChild(
                  showIfVideoNotInitialized: false,
                  child: LandscapePlayToggle(),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: const EdgeInsets.only(left: 30, right: 10),
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: IntrinsicWidth(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Phim "${widget.movieDetail.name}"',
                              style: const TextStyle(
                                fontSize: 20,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          Text(
                            ' - ${widget.movieEpisodeName[currentEpisodeIndex]}',
                            style: const TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  color: const Color.fromRGBO(0, 0, 0, 0.4),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 18,
                            child: FlickVideoProgressBar(
                              flickProgressBarSettings:
                                  FlickProgressBarSettings(
                                height: 5,
                                handleRadius: 6,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0,
                                  vertical: 10,
                                ),
                                backgroundColor: Colors.white24,
                                bufferedColor: Colors.white38,
                                getPlayedPaint: (
                                    {double? handleRadius,
                                    double? height,
                                    double? playedPart,
                                    double? width}) {
                                  return Paint()
                                    ..shader = const LinearGradient(colors: [
                                      Color.fromRGBO(108, 165, 242, 1),
                                      Color.fromRGBO(97, 104, 236, 1)
                                    ], stops: [
                                      0.0,
                                      0.5
                                    ]).createShader(
                                      Rect.fromPoints(
                                        const Offset(0, 0),
                                        Offset(width!, 0),
                                      ),
                                    );
                                },
                                getHandlePaint: (
                                    {double? handleRadius,
                                    double? height,
                                    double? playedPart,
                                    double? width}) {
                                  return Paint()
                                    ..shader = const RadialGradient(
                                      colors: [
                                        Colors.white,
                                        Colors.white,
                                        Colors.white,
                                      ],
                                      stops: [0.0, 0.4, 0.5],
                                      radius: 0.4,
                                    ).createShader(
                                      Rect.fromCircle(
                                        center:
                                            Offset(playedPart!, height! / 2),
                                        radius: handleRadius!,
                                      ),
                                    );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Expanded(
                            flex: 1,
                            child: FlickLeftDuration(),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const SizedBox(
                                  width: 5,
                                ),
                                PopupMenuButton(
                                  onOpened: () {
                                    if (videoManager.isPlaying) {
                                      controlManager.togglePlay();
                                    }
                                  },
                                  itemBuilder: (context) => playbackSpeeds
                                      .map((speed) => PopupMenuItem(
                                            height: 30,
                                            value: speed,
                                            child: Text(
                                              'x$speed',
                                            ),
                                          ))
                                      .toList(),
                                  onSelected: (newSpeed) {
                                    setState(() {
                                      playBackSpeed = newSpeed;
                                    });
                                    controlManager
                                        .setPlaybackSpeed(playBackSpeed);
                                    controlManager.togglePlay();
                                  },
                                  offset: const Offset(120, 0),
                                  position: PopupMenuPosition.over,
                                  // icon: Icon(Icons.speed_sharp),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.speed_sharp,
                                        size: widget.iconSize,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Tốc độ (x$playBackSpeed)',
                                        style: const TextStyle(fontSize: 12),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                FlickSoundToggleCustom(
                                  size: widget.iconSize,
                                ),
                                widget.initialEpisodeIndex > 0
                                    ? TextButton(
                                        onPressed: goToPreviousEpisode,
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.skip_previous,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              'Tập trước',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ))
                                    : const SizedBox(),
                                widget.initialEpisodeIndex <
                                        widget.episodesLength - 1
                                    ? TextButton(
                                        onPressed: goToNextEpisode,
                                        child: const Row(
                                          children: [
                                            Text(
                                              'Tập tiếp',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Icon(
                                              Icons.skip_next,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ))
                                    : const SizedBox(),
                                Visibility(
                                    visible:
                                        widget.movieDetail.type != 'single',
                                    child: MaterialButton(
                                      onPressed: () {
                                        openEpisodeDialog();
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.video_library,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'Danh sách tập',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      ),
                                    ))
                              ],
                            ),
                            IconButton(
                                onPressed: () {
                                  if (stateController.loginState.value) {
                                    HistoryFirebaseController
                                        .updateWatchingTime(
                                            widget.movieDetail.slug.toString(),
                                            widget.movieEpisodeName[
                                                currentEpisodeIndex],
                                            videoManager.videoPlayerValue!
                                                .position.inMinutes
                                                .toInt());
                                  }
                                  movieController.initSeekTime();
                                  SystemChrome.setEnabledSystemUIMode(
                                      SystemUiMode.manual,
                                      overlays: SystemUiOverlay.values);
                                  SystemChrome.setPreferredOrientations(
                                      [DeviceOrientation.portraitUp]);
                                  stateController.enableAutoPlay();
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.fullscreen_exit,
                                  size: 30,
                                ))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
