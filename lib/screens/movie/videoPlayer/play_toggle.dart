
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LandscapePlayToggle extends StatelessWidget {
  const LandscapePlayToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlickControlManager controlManager =
    Provider.of<FlickControlManager>(context);
    FlickVideoManager videoManager = Provider.of<FlickVideoManager>(context);

    Duration duration = const Duration(seconds: 10);

    double size = 80;
    Color color = Colors.white;

    Widget playWidget = Icon(
      Icons.play_arrow,
      size: size,
      color: color,
    );
    Widget pauseWidget = Icon(
      Icons.pause,
      size: size,
      color: color,
    );
    Widget replayWidget = Icon(
      Icons.replay,
      size: size,
      color: color,
    );

    Widget child = videoManager.isVideoEnded
        ? replayWidget
        : videoManager.isPlaying
        ? pauseWidget
        : playWidget;

    return Material(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(100),
            splashColor: const Color.fromRGBO(108, 165, 242, 0.1),
            key: key,
            onTap: () {
              controlManager.seekBackward(duration);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.all(10),
              child: const Icon(Icons.fast_rewind,
              size: 35,),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 50,right: 50),
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              splashColor: const Color.fromRGBO(108, 165, 242, 0.1),
              key: key,
              onTap: () {
                videoManager.isVideoEnded
                    ? controlManager.replay()
                    : controlManager.togglePlay();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.all(10),
                child: child,
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(100),
            splashColor: const Color.fromRGBO(108, 165, 242, 0.1),
            key: key,
            onTap: () {
              controlManager.seekForward(duration);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.all(10),
              child: const Icon(Icons.fast_forward,
              size: 35,),
            ),
          ),
        ],
      )
    );
  }
}