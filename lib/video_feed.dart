import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
        voiceSourceText: "XXXXXX"),
    VideoFeed(
        url:
            'https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4',
        userName: "lh",
        text: "好好玩吗",
        voiceSourceText: "XXXXXX")
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

class VideoFeedsState extends State<VideoFeeds> {
  @override
  Widget build(BuildContext context) {
    var model = ViewModelProvider.of<VideoFeedModel>(context);

    return PageView.builder(
      onPageChanged: (index) {
        if (index < model.videoFeeds.length) {
          model.currentVideoFeed.value = model.videoFeeds[index];
        }
      },
      scrollDirection: Axis.vertical,
      itemCount: model.videoFeeds.length + 1,
      itemBuilder: (context, index) {
        if (index == model.videoFeeds.length) {
          return LinearProgressIndicator();
        } else {
          return VideoFeedScreen(videoFeed: model.videoFeeds[index]);
        }
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
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      widget.videoFeed.text,
                      style: TextStyle(color: Colors.white),
                    ),
                    MarqueeText(
                      text: widget.videoFeed.voiceSourceText,
                      style: TextStyle(color: Colors.white),
                      width: 90,
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
                  )
                ],
              )
            ],
          ),
          bottom: 10,
          left: 10,
          right: 10,
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
