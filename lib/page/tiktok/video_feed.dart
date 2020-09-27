import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/page/tiktok/user_profile.dart';
import 'package:flutter_app/utils.dart';
import 'package:flutter_app/widgets.dart';
import 'package:observable_ui/core2.dart';
import 'package:observable_ui/provider.dart';
import 'package:video_player/video_player.dart';

import '../../amazing_page_view.dart';
import '../../bottom_sheet.dart' as AutoBottomSheet;
import '../../data_source.dart';
import '../../entities.dart';

class VideoFeedModel {
  ValueNotifier<VideoFeed> currentVideoFeed = ValueNotifier(null);

  ListenableList<VideoFeed> videoFeeds = ListenableList(initValue: VIDEO_FEEDS);
}

class VideoFeedsScreen extends StatefulWidget {
  @override
  VideoFeedsScreenState createState() {
    return VideoFeedsScreenState();
  }
}

///抖音的效果是over scroll之后 PageView悬停
class VideoFeedsScreenState extends State<VideoFeedsScreen> {
  PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    var model = ViewModelProvider.of<VideoFeedModel>(context);
    return Column(
      children: <Widget>[
        Expanded(
          child: AmazingPageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              model.currentVideoFeed.value = model.videoFeeds[index];
            },
            scrollDirection: Axis.vertical,
            itemCount: model.videoFeeds.length,
            loadMoreFooter: TikTokIndicator(),
            onLoadMore: () {
              return Future.delayed(Duration(seconds: 10), () {
                setState(() {
                  var addedItems = [
                    VideoFeed(
                        url:
                            'https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4',
                        userName: "lcw",
                        text: "app好玩",
                        voiceSourceText: "@廖布斯创作的原声-廖布斯"),
                    VideoFeed(
                        url:
                            'https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4',
                        userName: "lh",
                        text: "下大雨",
                        voiceSourceText: "@周星驰创作的原声-周星驰")
                  ];
                  model.videoFeeds.addAll(addedItems);
                });
              });
            },
            itemBuilder: (context, index) {
              return VideoFeedScreen(
                  videoFeedModel: model, videoFeed: model.videoFeeds[index]);
            },
          ),
        ),
      ],
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

  GlobalKey<CommentBottomSheetState> commentBottomSheetKey = GlobalKey();

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
    return Container(
      child: Stack(
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
                    GestureDetector(
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.message,
                            color: Colors.white,
                          ),
                          Text(
                            "评论",
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                      onTap: () {
                        CommentBottomSheetState state = (commentBottomSheetKey
                                .currentContext as StatefulElement)
                            .state as CommentBottomSheetState;
                        state.show();
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: <Widget>[
                        Icon(
                          Icons.share,
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
          ),
          Positioned(
              left: 0,
              right: 0,
              top: 200,
              bottom: 0,
              child: CommentBottomSheet(key: commentBottomSheetKey))
        ],
      ),
      color: Colors.black,
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

class CommentBottomSheet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CommentBottomSheetState();
  }

  CommentBottomSheet({Key key}) : super(key: key);
}

class CommentBottomSheetState extends State<CommentBottomSheet> {
  GlobalKey key = GlobalKey();


  @override
  void initState() {
    super.initState();
  }

  show() {
    (key.currentState as AutoBottomSheet.DraggableScrollableSheetState)
        .expand(true);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AutoBottomSheet.DraggableScrollableSheet(
        key: key,
        minChildSize: 0.0,
        maxChildSize: 1.0,
        initialChildSize: 0.0,
        expand: true,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            color: Colors.white,
            child: ListView.builder(
              controller: scrollController,
              itemCount: TikTokComments.length,
              itemBuilder: (BuildContext context, int index) {
                return CommentItem(TikTokComments[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class CommentItem extends StatefulWidget {
  final TiTokComment tiktokComment;

  const CommentItem(
    this.tiktokComment, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CommentItemState();
  }
}

class CommentItemState extends State<CommentItem> {
  @override
  Widget build(BuildContext context) {
    return _buildItem();
  }

  Widget _buildItem() {
    var subComments = this.widget.tiktokComment.subComments.map((comment) {
      return Container(
        child: SingleComment(2, comment),
        margin: EdgeInsets.only(top: 8),
      );
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: SingleComment(1, this.widget.tiktokComment.mainComment),
          margin: EdgeInsets.only(left: 16, right: 16),
        ),
        Container(
          margin: EdgeInsets.only(left: 58, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ...subComments,
              Container(
                child: GestureDetector(
                  child: Text(
                    "---展开更多回复",
                    style: TextStyle(color: Color.fromARGB(255, 171, 171, 171)),
                  ),
                  onTap: () {
                    setState(() {
                      this.widget.tiktokComment.subComments.add(Comment(
                            "我是展开评论",
                            FRIENDS[3],
                            likeCount: 111,
                          ));
                    });
                  },
                ),
                margin: EdgeInsets.only(top: 8, bottom: 8),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class SingleComment extends StatefulWidget {
  final num type; //1 主评论  2  子评论

  final Comment content;

  const SingleComment(this.type, this.content, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SingleCommentState();
  }
}

class SingleCommentState extends State<SingleComment> {
  TapGestureRecognizer _tapGestureRecognizer;

  @override
  void initState() {
    super.initState();

    _tapGestureRecognizer = TapGestureRecognizer()..onTap = handleTap;
  }

  @override
  void dispose() {
    super.dispose();
    _tapGestureRecognizer.dispose();
  }

  void handleTap() {
    print("onTap");
  }

  @override
  Widget build(BuildContext context) {
    double avatarSize = this.widget.type == 1 ? 36 : 18;
    double avatarRightMargin = this.widget.type == 1 ? 12 : 8;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        buildCircleImage(
            avatarSize, NetworkImage(this.widget.content.poster.avatar)),
        SizedBox(
          width: avatarRightMargin,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                this.widget.content.poster.name,
                style: TextStyle(color: Color.fromARGB(255, 154, 155, 158)),
              ),
              SizedBox(
                height: 4,
              ),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: "@新垣结衣",
                      style: TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(255, 235, 201, 108)),
                      recognizer: _tapGestureRecognizer),
                  TextSpan(
                      text: "我的第一天评论",
                      style: TextStyle(color: Colors.black, fontSize: 15)),
                  TextSpan(
                    text: "13分钟前",
                    style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 174, 174, 174)),
                  )
                ]),
              ),
            ],
          ),
        ),
        GestureDetector(
          child: Column(
            children: <Widget>[
              Icon(
                Icons.favorite,
                size: 20,
                color:
                    this.widget.content.iLike ? Colors.redAccent : Colors.black,
              ),
              Text(
                this.widget.content.likeCount.toString(),
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          onTap: () {
            setState(() {
              this.widget.content.iLike = !this.widget.content.iLike;
              this.widget.content.likeCount +=
                  this.widget.content.iLike ? 1 : -1;
            });
          },
        ),
      ],
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

class IndeterminateProgress extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return IndeterminateProgressState();
  }
}

class IndeterminateProgressState extends State<IndeterminateProgress>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
        upperBound: 4,
        lowerBound: 1)
      ..repeat();
  }

  @override
  Widget build(BuildContext context) {
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
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class ProgressRegulatorState extends State<ProgressRegulator> {
  bool _adjusting = false;

  double _adjustingValue = 0.0;

  void Function() _listener;

  @override
  void initState() {
    super.initState();
    _listener = () {
      setState(() {});
    };
    widget.videoPlayerController.addListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    VideoPlayerValue playerValue = widget.videoPlayerController.value;
    //视频还未加载完全,显示动画
    if (playerValue.duration == null) {
      return IndeterminateProgress();
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
    super.dispose();
    widget.videoPlayerController.removeListener(_listener);
  }
}

///抖音正在加载中动画效果
class TikTokIndicator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TikTokIndicatorState();
  }
}

class TikTokIndicatorState extends State<TikTokIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
        upperBound: 1,
        lowerBound: 0)
      ..repeat();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      alignment: Alignment.bottomCenter,
      child: CustomPaint(
        painter: TikTokIndicatorPainter(_controller.value),
        size: Size(100, 100),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class TikTokIndicatorPainter extends CustomPainter {
  final double progress;

  double maxRadius = 8;

  double minRadius = 6;

  TikTokIndicatorPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    print(size);
    double yCenter = size.height / 2;
    double xCenter = size.width / 2;
    // double circle1XCenter = 2 * maxRadius * progress + xCenter - maxRadius;
    double circle1XCenter = -8 * maxRadius * progress * progress +
        8 * maxRadius * progress +
        xCenter -
        maxRadius;

    double circle1Radius = (maxRadius - minRadius) * 4 * progress * progress -
        4 * (maxRadius - minRadius) * progress +
        maxRadius;

    double circle2XCenter = 8 * maxRadius * progress * progress -
        8 * maxRadius * progress +
        maxRadius +
        xCenter;

    double circle2XRadius = (-maxRadius + minRadius) * 4 * progress * progress +
        (maxRadius - minRadius) * 4 * progress +
        minRadius;
    if (progress <= 0.5) {
      canvas.saveLayer(Rect.fromLTRB(0, 0, size.width, size.height), paint);
      paint.color = Colors.red;
      canvas.drawCircle(Offset(circle1XCenter, yCenter), circle1Radius, paint);
      paint.blendMode = BlendMode.xor;
      paint.color = Colors.blue;
      canvas.drawCircle(Offset(circle2XCenter, yCenter), circle2XRadius, paint);
      canvas.restore();
    } else {
      canvas.saveLayer(Rect.fromLTRB(0, 0, size.width, size.height), paint);
      paint.color = Colors.blue;
      canvas.drawCircle(Offset(circle2XCenter, yCenter), circle2XRadius, paint);
      paint.color = Colors.red;
      paint.blendMode = BlendMode.xor;
      canvas.drawCircle(Offset(circle1XCenter, yCenter), circle1Radius, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
