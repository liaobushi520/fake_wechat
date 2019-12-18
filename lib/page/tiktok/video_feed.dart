import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/utils.dart';
import 'package:flutter_app/widgets.dart';
import 'package:observable_ui/core2.dart';
import 'package:observable_ui/provider.dart';
import 'package:video_player/video_player.dart';

import '../../entities.dart';

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
  double _tabBarLeft = 0;

  double _tabBarIndicatorRadio = 0;

  PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return ViewModelProvider(
      viewModel: VideoFeedModel(),
      child: Scaffold(
        body: Container(
          color: Colors.black,
          child: NotificationListener(
            child: Stack(
              children: <Widget>[
                PageView(
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    VideoFeeds(),
                    VideoFeeds(),
                    PersonProfileScreen()
                  ],
                ),
                Positioned(
                  child: SafeArea(
                    child: Center(
                      child: TabBar(
                        radio: _tabBarIndicatorRadio,
                        onSelected: (pos) {
                          _pageController.animateToPage(pos,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.ease);
                        },
                      ),
                    ),
                  ),
                  left: _tabBarLeft,
                  right: -_tabBarLeft,
                  top: 10,
                ),
              ],
            ),
            onNotification: (ScrollNotification notification) {
              if (notification is ScrollUpdateNotification &&
                  notification.metrics is PageMetrics) {
                if (notification.metrics.pixels >=
                    notification.metrics.viewportDimension) {
                  var delta = (notification.metrics.pixels -
                      notification.metrics.viewportDimension);
                  setState(() {
                    _tabBarLeft = -delta;
                  });
                } else {
                  var radio = (notification.metrics.pixels /
                          notification.metrics.viewportDimension)
                      .clamp(0, 1);
                  setState(() {
                    _tabBarIndicatorRadio = radio;
                  });
                }
              }
              return true;
            },
          ),
        ),
      ),
    );
  }
}

class TabBar extends StatefulWidget {
  final double radio;

  final void Function(int pos) onSelected;

  const TabBar({Key key, this.radio, this.onSelected}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TabBarState();
  }
}

class TabBarState extends State<TabBar> {
  static const TAB_WIDTH = 70.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              child: Container(
                child: Text(
                  "关注",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                width: TAB_WIDTH,
              ),
              onTap: () {
                widget.onSelected(0);
              },
            ),
            GestureDetector(
              child: Container(
                child: Text(
                  "推荐",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                width: TAB_WIDTH,
              ),
              onTap: () {
                widget.onSelected(1);
              },
            )
          ],
        ),
        SizedBox(
          height: 6,
        ),
        SizedBox(
          width: TAB_WIDTH * 2,
          height: 2,
          child: Align(
            alignment: Alignment(2 * widget.radio - 1, 0),
            child: Container(
              width: TAB_WIDTH,
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Container(
                decoration: BoxDecoration(color: Colors.white),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class VideoFeeds extends StatefulWidget {
  @override
  VideoFeedsState createState() {
    return VideoFeedsState();
  }
}

///抖音的效果是over scroll之后 PageView悬停
class VideoFeedsState extends State<VideoFeeds> {
  bool indicatorVisible = false;

  PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    var model = ViewModelProvider.of<VideoFeedModel>(context);
    return NotificationListener(
      child: Column(
        children: <Widget>[
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                model.currentVideoFeed.value = model.videoFeeds[index];
              },
              scrollDirection: Axis.vertical,
              itemCount: model.videoFeeds.length,
              itemBuilder: (context, index) {
                return VideoFeedScreen(
                    videoFeedModel: model, videoFeed: model.videoFeeds[index]);
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

  final VideoFeedModel videoFeedModel;

  const VideoFeedScreen({Key key, this.videoFeed, this.videoFeedModel})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return VideoFeedScreenState();
  }
}

///涉及的细节是网络视频，一边播放一边缓存

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
        ///如果是当前页，就立即播放
        if (widget.videoFeedModel.currentVideoFeed.value == widget.videoFeed) {
          setState(() {
            _controller.play();
          });
        } else {
          setState(() {
            _controller.pause();
          });
        }
      })
      ..setLooping(true);

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
            videoPlayerController: _controller,
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
    if (model.currentVideoFeed.value == null) {
      return Text("个人主页");
    }

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
    _controller?.dispose();
    super.dispose();
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
  final VideoPlayerController videoPlayerController;

  const ProgressRegulator({Key key, this.videoPlayerController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ProgressRegulatorState();
  }
}

class ProgressRegulatorState extends State<ProgressRegulator>
    with SingleTickerProviderStateMixin {
  bool _adjusting = false;

  double _adjustingValue = 0.0;

  void Function() _listener;

  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _listener = () {
      print(widget.videoPlayerController.value);
      setState(() {});
    };
    widget.videoPlayerController.addListener(_listener);

    _controller = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
        upperBound: 4,
        lowerBound: 1)
      ..repeat();
  }

  Widget _buildIndeterminateProgress() {
    return Container(
      height: _kProgressRegulatorIntrinsicHeight,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            height: 1,
            color: Color(0x66bdbdbd),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transformHitTests: true,
                child: child,
                transform: Matrix4.diagonal3Values(_controller.value, 1.0, 1.0),
              );
            },
            child: Container(
              alignment: Alignment.center,
              height: 1,
              width: 100,
              color: Color(0xffbdbdbd),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    VideoPlayerValue playerValue = widget.videoPlayerController.value;
    //视频还未加载完全,显示动画
    if (playerValue.duration == null) {
      return _buildIndeterminateProgress();
    }

    return Column(
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
                      text: "${formatHHmmSS(_adjustingValue)}",
                      style: TextStyle(color: Colors.white, fontSize: 22)),
                  TextSpan(
                      text:
                          " /${formatHHmmSS(playerValue.duration.inSeconds.toDouble())}",
                      style: TextStyle(color: Color(0xffbdbdbd), fontSize: 22))
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
              max: playerValue.duration.inSeconds.toDouble(),
              value: _adjusting
                  ? _adjustingValue
                  : playerValue.position.inSeconds.toDouble(),
              onChangeEnd: (value) {
                setState(() {
                  _adjusting = false;
                  widget.videoPlayerController
                      .seekTo(Duration(seconds: value.toInt()));
                });
              },
              onChanged: (value) {
                setState(() {
                  _adjusting = true;
                  _adjustingValue = value;
                });
              },
            ),
            height: _kProgressRegulatorIntrinsicHeight,
          ),
          data: SliderTheme.of(context).copyWith(
            showValueIndicator: ShowValueIndicator.always,
            thumbColor: Colors.white,
            activeTrackColor: Colors.white,
            inactiveTrackColor:
                _adjusting ? Color(0x66bdbdbd) : Colors.transparent,
            trackHeight: _adjusting ? 3 : 1,
            thumbShape:
                RoundSliderThumbShape(enabledThumbRadius: _adjusting ? 4 : 0),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
    widget.videoPlayerController.removeListener(_listener);
  }
}

class IndeterminateProgress extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    throw UnimplementedError();
  }
}
