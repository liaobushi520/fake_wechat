import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/utils.dart';
import 'package:flutter_app/widgets.dart';
import 'package:observable_ui/core2.dart';
import 'package:observable_ui/provider.dart';
import 'package:video_player/video_player.dart';

import 'entities.dart';

class VideoFeedModel {
  ValueNotifier<VideoFeed> currentVideoFeed = ValueNotifier(null);

  ListenableList<VideoFeed> videoFeeds = ListenableList(initValue: [
    VideoFeed(
        url:
            'https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4',
        userName: "lzj",
        text: "好好玩",
        voiceSourceText: "@廖布斯创作的原声-廖布斯"),
    VideoFeed(
        url:
            'https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4',
        userName: "lh",
        text: "好好玩吗",
        voiceSourceText: "@周星驰创作的原声-周星驰")
  ]);
}

class VideoFeedPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return VideoFeedPageState();
  }
}

class VideoFeedPageState extends State<VideoFeedPage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelProvider(
      viewModel: VideoFeedModel(),
      child: Scaffold(
        body: Container(
          color: Colors.black,
          child: PageView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              VideoFeeds(),
              VideoFeeds(),
              PersonProfileScreen()
            ],
          ),
        ),
      ),
    );
  }
}

class VideoFeeds extends StatefulWidget {
  @override
  VideoFeedsState createState() {
    return VideoFeedsState();
  }
}

///抖音的效果是over scroll之后 PageView悬停 ，太难了 ，暂时搞不定

class VideoFeedsState extends State<VideoFeeds> {
  bool indicatorVisible = false;

  @override
  Widget build(BuildContext context) {
    var model = ViewModelProvider.of<VideoFeedModel>(context);

    return NotificationListener(
      child: Column(
        children: <Widget>[
          Expanded(
            child: PageView.builder(
              onPageChanged: (index) {
                model.currentVideoFeed.value = model.videoFeeds[index];
              },
              scrollDirection: Axis.vertical,
              itemCount: model.videoFeeds.length,
              itemBuilder: (context, index) {
                return VideoFeedScreen(videoFeed: model.videoFeeds[index]);
              },
            ),
          ),
          Visibility(
            child: CircularProgressIndicator(),
            visible: indicatorVisible,
          )
        ],
      ),
      onNotification: (ScrollNotification notification) {
//        print(notification);
//        if (notification.depth == 0 && notification is ScrollEndNotification) {
//          setState(() {
//            indicatorVisible = true;
//            Future.delayed(Duration(seconds: 5), () {
//              setState(() {
//                indicatorVisible = false;
//              });
//            });
//          });
//        }

        return true;
      },
    );
  }
}

class VideoFeedScreen extends StatefulWidget {
  final VideoFeed videoFeed;

  const VideoFeedScreen({Key key, this.videoFeed}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return VideoFeedScreenState();
  }
}

class VideoFeedScreenState extends State<VideoFeedScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  VideoPlayerController _controller;

  AnimationController _scaleController;

  Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoFeed.url)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          _controller.play();
        });
      });

    _scaleController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    final Animation curve =
        CurvedAnimation(parent: _scaleController, curve: Curves.bounceIn);

    scaleAnimation = Tween<double>(begin: 2.0, end: 1.0).animate(curve);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: <Widget>[
        GestureDetector(
          child: Stack(
            children: <Widget>[
              Center(
                child: _controller.value.initialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : Container(),
              ),
              Center(
                child: ScaleTransition(
                    scale: scaleAnimation,
                    child: _controller.value.isPlaying
                        ? SizedBox(
                            width: 80,
                            height: 80,
                          )
                        : SizedBox(
                            width: 80,
                            height: 80,
                            child: Icon(
                              Icons.play_arrow,
                              size: 80,
                            ),
                          )),
              ),
            ],
          ),
          onTap: () {
            setState(() {
              if (_controller.value.isPlaying) {
                _controller.pause();
                _scaleController.forward(from: 2.0);
              } else {
                _controller.play();
                //   _scaleController.;
              }
            });
          },
        ),
        Positioned(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.videoFeed.userName,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      widget.videoFeed.text,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    MarqueeText(
                      text: widget.videoFeed.voiceSourceText,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      width: 160,
                      height: 20,
                    )
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Icon(
                        Icons.message,
                        color: Colors.white,
                      ),
                      Text(
                        "分享",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  Jukebox()
                ],
              )
            ],
          ),
          bottom: _kProgressRegulatorIntrinsicHeight,
          left: 10,
          right: 10,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ProgressRegulator(
            duration: 100,
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

class PersonProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PersonProfileScreenState();
  }
}

class PersonProfileScreenState extends State<PersonProfileScreen> {
  @override
  Widget build(BuildContext context) {
    var model = ViewModelProvider.of<VideoFeedModel>(context);

    return Center(
      child: Text("个人主页" + model.currentVideoFeed.value.userName),
    );
  }
}

class Jukebox extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return JukeboxState();
  }
}

class JukeboxState extends State<Jukebox> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      child: Container(
        child: Stack(
          children: <Widget>[buildCircleImage(40, NetworkImage(AVATAR[0]))],
        ),
      ),
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2.0 * pi,
          child: child,
        );
      },
    );
  }
}

const _kProgressRegulatorIntrinsicHeight = 10.0;

class ProgressRegulator extends StatefulWidget {
  final double duration;

  const ProgressRegulator({Key key, this.duration}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ProgressRegulatorState();
  }
}

class ProgressRegulatorState extends State<ProgressRegulator> {
  double _currentProgress = 0;

  bool _adjusting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Column(
        children: <Widget>[
          Visibility(
            child: CustomPaint(
              child: Container(
                color: Colors.black,
                width: double.infinity,
                padding: EdgeInsets.only(top: 30, bottom: 30),
                alignment: Alignment.center,
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: "04:10",
                        style: TextStyle(color: Colors.white, fontSize: 22)),
                    TextSpan(
                        text: " /08:10",
                        style:
                            TextStyle(color: Color(0xffbdbdbd), fontSize: 22))
                  ]),
                ),
              ),
            ),
            visible: _adjusting,
          ),
          SliderTheme(
            child: SizedBox(
              child: Slider(
                min: 0,
                max: 100,
                value: _currentProgress,
                onChangeEnd: (value) {
                  setState(() {
                    _adjusting = false;
                  });
                },
                onChanged: (value) {
                  setState(() {
                    _currentProgress = value;
                    _adjusting = true;
                  });
                },
              ),
              height: _kProgressRegulatorIntrinsicHeight,
            ),
            data: SliderTheme.of(context).copyWith(
              showValueIndicator: ShowValueIndicator.always,
              trackHeight: _adjusting ? 3 : 1,
              thumbShape:
                  RoundSliderThumbShape(enabledThumbRadius: _adjusting ? 4 : 0),
            ),
          )
        ],
      ),
    );
  }
}
