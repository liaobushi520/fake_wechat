import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/page/qqmusic/music_player_page.dart';
import 'package:flutter_app/utils.dart';
import 'package:observable_ui/provider.dart';

import '../../app_model.dart';
import '../../data_source.dart';
import '../../entities.dart';
import '../../memonts_model.dart';
import '../qqmusic/audio_player.dart';

enum CommentAction { like, comment }

class MomentsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MomentsState();
  }
}

class CommentEdit extends StatefulWidget {
  CommentEdit(Key key) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CommentEditState();
  }
}

class CommentEditState extends State<CommentEdit> {
  bool _show = false;

  void Function(String text) _onSend;

  String _text;

  FocusNode _focusNode = FocusNode();

  TextEditingController _textEditingController = TextEditingController();

  handleCommentEvent(CommentEditNotification notification) {
    if (_show != notification.show) {
      setState(() {
        _show = notification.show;
        if (_show) {
          _focusNode.requestFocus();
        }
      });
    }
    _onSend = notification.onSend;
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      child: Positioned(
        left: 0, //widget距离stack左边界距离 ，width = stack宽 - left - right
        right: 0,
        bottom: 0,
        child: Container(
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Container(
                child: DecoratedBox(
                  child: Padding(
                    child: TextField(
                      controller: _textEditingController,
                      focusNode: _focusNode,
                      decoration: null,
                      maxLines: 5,
                      minLines: 1,
                      textAlign: TextAlign.start,
                      cursorColor: Color.fromARGB(255, 87, 189, 105),
                      style: TextStyle(color: Color(0xff000000), fontSize: 16),
                      onChanged: (text) {
                        _text = text;
                      },
                    ),
                    padding: EdgeInsets.all(10),
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                      color: Colors.white),
                ),
              )),
              FlatButton(
                child: Text("发送"),
                onPressed: () {
                  if (_onSend != null) {
                    _onSend(_text);
                  }
                  setState(() {
                    _show = false;
                    _text = "";
                    _textEditingController.text = "";
                  });
                },
              )
            ],
          ),
          color: Color.fromARGB(255, 247, 247, 247),
          padding: EdgeInsets.only(left: 8, top: 4, right: 8, bottom: 4),
        ),
      ),
      visible: _show,
    );
  }
}

class CommentEditNotification extends Notification {
  final void Function(String text) onSend;

  final bool show;

  CommentEditNotification(this.show, {this.onSend});
}

class ScrollEvent {
  final double offset;

  final int type;

  const ScrollEvent({this.offset, this.type});

  ///1 :用户手指在拖拽    2:用户手指停止拖拽，但需要继续动画   3：结束

}

class MomentRefreshIndicator extends StatefulWidget {
  const MomentRefreshIndicator({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MomentRefreshIndicatorState();
  }
}

class MomentRefreshIndicatorState extends State with TickerProviderStateMixin {
  static final MAX_TRANSLATE_Y = 100.0;

  AnimationController _rotateController, _translateController;

  double _angle = 0.0;

  double _translateY = 0.0;

  handleScrollEvent(ScrollEvent event) {
    print("${event.type} ${event.offset}");
    if (event.type == 1) {
      setState(() {
        _translateY = min(MAX_TRANSLATE_Y, -event.offset);
        _angle = -event.offset;
      });
    } else if (event.type == 2) {
      //开始一个旋转动画
      _rotateController
        ..repeat()
        ..addListener(() {
          setState(() {
            _angle = _rotateController.value;
          });
        });
    } else {
      //开始一个平移动画
      _rotateController.stop();
      _translateController.addListener(() {
        setState(() {
          _translateY = _translateController.value;
        });
      });
      _translateController.reverse(from: _translateY);
    }
  }

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
        lowerBound: 0.0,
        upperBound: 2 * pi);

    _translateController = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
        lowerBound: 0.0,
        upperBound: MAX_TRANSLATE_Y);
  }

  Widget _child = Icon(
    Icons.camera,
    size: 30,
  );

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, _translateY),
      child: Transform.rotate(angle: _angle, child: _child),
    );
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _translateController.dispose();
    super.dispose();
  }
}

class MomentsState extends State<MomentsPage> {
  GlobalKey _commentEditKey = GlobalKey();

  GlobalKey _indicatorKey = GlobalKey();

  bool _refreshing = false;

  Widget _buildCover() {
    return Stack(
      children: <Widget>[
        Container(
          child: Image.network(
            "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3129531823,304476160&fm=26&gp=0.jpg",
            fit: BoxFit.cover,
            height: 280,
            width: double.infinity,
          ),
          padding: EdgeInsets.only(bottom: 30),
        ),
        Positioned(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    "来哦布斯",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        image: DecorationImage(
                            image: NetworkImage(
                                "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3129531823,304476160&fm=26&gp=0.jpg"),
                            fit: BoxFit.cover)),
                  )
                ],
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                "我是一个好人",
                style: TextStyle(fontSize: 12, color: Color(0xff515151)),
              )
            ],
          ),
          right: 16,
          bottom: 0,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var model = ViewModelProvider.of<MomentsModel>(context);
    return Scaffold(
      //捕获回退键
      body: NotificationListener(
        child: WillPopScope(
          child: Stack(
            children: <Widget>[
              CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
//                    SliverAppBar(
//                      pinned: true,
//                      stretch: true,
//                      actions: <Widget>[
//                        IconButton(
//                          icon: Icon(Icons.camera),
//                          onPressed: () => {
//                            showDialog(
//                                context: context,
//                                builder: (context) {
//                                  var body = [
//                                    Card(
//                                      child: Column(
//                                        crossAxisAlignment:
//                                            CrossAxisAlignment.start,
//                                        children: <Widget>[
//                                          Row(
//                                            children: <Widget>[
//                                              Expanded(
//                                                child: Text("拍摄",
//                                                    style: TextStyle(
//                                                        color: Colors.black,
//                                                        fontSize: 16)),
//                                              ),
//                                              Align(
//                                                child: Text("照片或视频",
//                                                    style: TextStyle(
//                                                        color: Colors.black54,
//                                                        fontSize: 10)),
//                                                alignment: Alignment.centerLeft,
//                                              ),
//                                            ],
//                                          ),
//                                          Divider(
//                                            height: 1,
//                                          ),
//                                          Text(
//                                            "从相册选择",
//                                            style: TextStyle(
//                                                color: Colors.black,
//                                                fontSize: 16),
//                                            textAlign: TextAlign.left,
//                                          )
//                                        ],
//                                      ),
//                                    )
//                                  ];
//                                  Widget dialogChild = Column(
//                                    mainAxisSize: MainAxisSize.min,
//                                    crossAxisAlignment:
//                                        CrossAxisAlignment.stretch,
//                                    children: body,
//                                  );
//                                  return Dialog(
//                                    child: dialogChild,
//                                    backgroundColor: Colors.transparent,
//                                  );
//                                })
//                          },
//                        )
//                      ],
//                    ),
                    SliverToBoxAdapter(
                      child: _buildCover(),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        var item = model.moments[index];
                        switch (item.type) {
                          case 1:
                            return MomentItem(moment: item);
                          case 4:
                            return MomentItem(
                                child: AudioItem(moment: item), moment: item);
                          case 2:
                            return MomentItem(
                                child: buildImageGrid(item), moment: item);
                          default:
                            return MomentItem(
                                child: buildWebPageItem(item), moment: item);
                        }
                      }, childCount: model.moments.length),
                    )
                  ]),
              CommentEdit(_commentEditKey),
              Positioned(
                top: -30,
                left: 30,
                child: MomentRefreshIndicator(
                  key: _indicatorKey,
                ),
              )
            ],
          ),
          onWillPop: () {
            if (model.showCommentEdit.value) {
              model.showCommentEdit.value = false;
              return Future.value(false);
            }
            return Future.value(true);
          },
        ),
        onNotification: (notification) {
          print(notification);
          if (notification is ScrollNotification && !_refreshing) {
            MomentRefreshIndicatorState state =
                (_indicatorKey.currentContext as StatefulElement).state;
            if (notification is ScrollUpdateNotification &&
                notification.metrics.pixels <= 0) {
              //用户手指在拖拽
              if (notification.dragDetails != null) {
                state.handleScrollEvent(
                    ScrollEvent(type: 1, offset: notification.metrics.pixels));
              } else {
                if (notification.metrics.pixels < -140.0) {
                  _refreshing = true;
                  state.handleScrollEvent(ScrollEvent(
                      type: 2, offset: notification.metrics.pixels));
                  Future.delayed(Duration(seconds: 5), () {
                    _refreshing = false;
                    state.handleScrollEvent(ScrollEvent(
                        type: 3, offset: notification.metrics.pixels));
                  });
                } else {
                  state.handleScrollEvent(ScrollEvent(
                      type: 3, offset: notification.metrics.pixels));
                }
              }
            }

            print(notification.metrics.pixels);
          }

          if (notification is CommentEditNotification) {
            CommentEditState state =
                (_commentEditKey.currentContext as StatefulElement).state;
            state.handleCommentEvent(notification);
          } else if (notification is UserScrollNotification) {
            CommentEditState state =
                (_commentEditKey.currentContext as StatefulElement).state;
            state.handleCommentEvent(CommentEditNotification(false));
          } else if (notification is OverscrollNotification) {
            print(notification);
          }
          return true;
        },
      ),
    );
  }

  Widget buildImageGrid(Moment moment) {
    int rowCount = (moment.images.length / 3).round();
    var rows = <Row>[];
    for (int i = 0; i <= rowCount; i++) {
      var widgets = <Widget>[];
      for (int j = 3 * i; j < min(moment.images.length, 3 * (i + 1)); j++) {
        widgets.add(Expanded(
            child: Padding(
                padding: EdgeInsets.all(4),
                child: Image.network(moment.images[j]))));
      }
      rows.add(Row(
        children: widgets,
      ));
    }

    return Container(
        child: Column(
      children: rows,
    ));
  }

  Widget buildWebPageItem(Moment moment) {
    return Container(
      padding: EdgeInsets.all(2),
      color: Color(0xffeeeeee),
      child: Row(
        children: <Widget>[
          Image.network(
            moment.webPageLink.cover,
            width: 42,
            height: 42,
            fit: BoxFit.cover,
          ),
          SizedBox(
            width: 6,
          ),
          Text(
            moment.webPageLink.title,
            style: TextStyle(fontSize: 14),
          )
        ],
      ),
    );
  }
}

class MomentItem extends StatefulWidget {
  final Moment moment;

  final Widget child;

  const MomentItem({Key key, this.moment, this.child}) : super(key: key);

  @override
  MomentItemState createState() {
    return MomentItemState();
  }
}

class MomentItemState extends State<MomentItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 12, top: 8, right: 12, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                color: Color(0x77889911),
                child: Image.network(
                  this.widget.moment.friend.avatar,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        this.widget.moment.friend.name,
                        style: TextStyle(
                            color: Color.fromARGB(255, 93, 107, 143),
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      if (widget.moment.text != null) Text(widget.moment.text),
                      SizedBox(
                        height: 4,
                      ),
                      if (widget.child != null) widget.child,
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text("10分钟前"),
                          ),
                          CommentActions(
                            onLike: () {
                              this.setState(() {
                                this.widget.moment.likes.add(USER);
                              });
                            },
                            onComment: () {
                              CommentEditNotification(true, onSend: (text) {
                                setState(() {
                                  this
                                      .widget
                                      .moment
                                      .comments
                                      .add(Comment(text, USER));
                                });
                              }).dispatch(context);
                            },
                          ),
                        ],
                      ),
                      buildCommentSection(
                          this.widget.moment.likes, this.widget.moment.comments)
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        Divider(
          height: 1,
        )
      ],
    );
  }

  Widget buildCommentSection(List<Friend> likeFriends, List<Comment> comments) {
    if (isNullOrEmpty(likeFriends) && isNullOrEmpty(comments)) {
      return SizedBox(
        height: 0,
      );
    }
    var likesWidget = buildLikes(likeFriends);
    var commentsWidget = buildComments(comments);

    var children = <Widget>[];
    if (likesWidget != null) {
      children.add(likesWidget);
    }

    if (likesWidget != null && commentsWidget != null) {
      children.add(Divider());
    }

    if (commentsWidget != null) {
      children.add(commentsWidget);
    }

    return Container(
      color: Color.fromARGB(255, 245, 245, 245),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget buildComments(List<Comment> comments) {
    if (comments == null || comments.isEmpty) {
      return null;
    }
    var commentSpans = comments
        ?.map((comment) => Container(
                child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(children: [
                TextSpan(
                    text: comment.replyer == null
                        ? (comment.poster.name + ": ")
                        : comment.poster.name,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Color.fromARGB(255, 93, 107, 143))),
                if (comment.replyer != null)
                  TextSpan(
                    children: [
                      TextSpan(
                          text: "回复",
                          style: TextStyle(
                              color: Color.fromARGB(255, 106, 106, 106))),
                      TextSpan(
                          text: comment.replyer.name + ": ",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Color.fromARGB(255, 93, 107, 143)))
                    ],
                  ),
                TextSpan(
                    text: comment.text,
                    style: TextStyle(color: Color.fromARGB(255, 97, 97, 97)))
              ]),
            )))
        ?.toList();

    return Container(
      width: 1000,
      padding: EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: commentSpans,
      ),
    );
  }

  Widget buildLikes(List<Friend> likeFriends) {
    if (likeFriends == null || likeFriends.isEmpty) {
      return null;
    }

    print("${likeFriends.length}");
    final likeSpans =
        likeFriends?.map((friend) => TextSpan(text: friend.name))?.toList();

    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.favorite,
            size: 14,
          ),
          SizedBox(
            width: 4,
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                  children: likeSpans,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color.fromARGB(255, 93, 107, 143))),
            ),
          ),
        ],
      ),
      padding: EdgeInsets.all(4),
    );
  }
}

class CommentEditResult {
  final String content;

  final int status; //-1 no send 0 send

  CommentEditResult(this.status, this.content);
}

///音频
class AudioItem extends StatefulWidget {
  final Moment moment;

  const AudioItem({Key key, this.moment}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AudioItemState();
  }
}

class AudioItemState extends State<AudioItem> {
  @override
  Widget build(BuildContext context) {
    final appModel = ViewModelProvider.of<AppModel>(context);

    return GestureDetector(
      child: Container(
        color: Color(0xffeeeeee),
        padding: EdgeInsets.all(3),
        child: Row(
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Image.network(
                  this.widget.moment.audioLink.cover,
                  width: 42,
                  height: 42,
                ),
                Positioned(
                  child: GestureDetector(
                    onTap: () {
                      appModel.audioPlayer
                          .playOrStop(this.widget.moment.audioLink);
                    },
                    child: PlayOrPauseIcon(
                      audioLink: this.widget.moment.audioLink,
                      playStream: appModel.audioPlayer.playStream,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              width: 6,
            ),
            SizedBox(
              height: 42,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    this.widget.moment.audioLink.name,
                    style: TextStyle(color: Color(0xff3f51b5), fontSize: 14),
                  ),
                  Spacer(),
                  Text(
                    this.widget.moment.audioLink.artist,
                    style: TextStyle(fontSize: 14),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MusicPlayerPage(
              song: this.widget.moment.audioLink,
            ),
          ),
        );
      },
    );
  }
}

class PlayOrPauseIcon extends StatefulWidget {
  final AudioLink audioLink;

  final Stream playStream;

  const PlayOrPauseIcon({Key key, this.audioLink, this.playStream})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PlayOrPauseIconState();
  }
}

class PlayOrPauseIconState extends State<PlayOrPauseIcon> {
  PlayEvent _lastPlayEvent;

  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.playStream.listen((e) {
      if (_lastPlayEvent == null ||
          (e.audio != widget.audioLink &&
              _lastPlayEvent.audio == widget.audioLink) ||
          (widget.audioLink == e.audio && _lastPlayEvent.status != e.status)) {
        setState(() {});
      }
      _lastPlayEvent = e;
    });
  }

  bool _isPlay() {
    return _lastPlayEvent != null &&
        _lastPlayEvent.audio == widget.audioLink &&
        _lastPlayEvent.status == 1;
  }

  @override
  Widget build(BuildContext context) {
    return _isPlay() ? Icon(Icons.pause) : Icon(Icons.play_arrow);
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }
}

class CommentActions extends StatefulWidget {
  final void Function() onLike;

  final void Function() onComment;

  final bool popup;

  const CommentActions(
      {Key key, this.onLike, this.onComment, this.popup = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CommentActionsState();
  }
}

class CommentActionsState extends State<CommentActions> {
  final GlobalKey placeholderKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var actions = Material(
      child: Container(
        key: this.widget.popup ? null : this.placeholderKey,
        width: 150,
        color: Color(0xff000000),
        padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          children: <Widget>[
            GestureDetector(
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.comment,
                    color: Color(0xffffffff),
                    size: 16,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    "评论",
                    style: TextStyle(color: Color(0xffffffff), fontSize: 14),
                  )
                ],
              ),
              onTap: this.widget.onComment,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: VerticalDivider(
                  width: 1,
                  color: Color(0xff414141),
                ),
              ),
            ),
            GestureDetector(
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.comment,
                    color: Color(0xffffffff),
                    size: 16,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text("赞",
                      style: TextStyle(color: Color(0xffffffff), fontSize: 14))
                ],
              ),
              onTap: this.widget.onLike,
            ),
          ],
        ),
      ),
    );
    if (this.widget.popup) {
      return actions;
    }
    return Row(
      children: <Widget>[
        Opacity(
          child: actions,
          opacity: 0,
        ),
        IconButton(
            icon: Icon(
              Icons.more,
              size: 16,
            ),
            onPressed: _showCommentActionMenu)
      ],
    );
  }

  void _showCommentActionMenu() {
    var box = (placeholderKey.currentContext.findRenderObject() as RenderBox);
    var offset = box.localToGlobal(Offset(0, 0));
    Navigator.of(context, rootNavigator: false).push(CommentActionMenuRoute(
        position: RelativeRect.fromLTRB(
            offset.dx,
            offset.dy,
            offset.dx + box.paintBounds.width,
            offset.dy + box.paintBounds.height),
        onLike: this.widget.onLike,
        onComment: this.widget.onComment,
        showMenuContext: context));
  }
}

typedef TapCallback<T> = void Function(T extras);

class LinkText<T> extends StatefulWidget {
  const LinkText(this.text, {this.extra, this.onTap});

  final String text;

  final T extra;

  final TapCallback<T> onTap;

  @override
  State<StatefulWidget> createState() {
    return LinkTextState();
  }
}

class LinkTextState extends State<LinkText> {
  TapGestureRecognizer _tapGestureRecognizer;

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer = TapGestureRecognizer();
    _tapGestureRecognizer.onTap = () => widget.onTap(widget.extra);
  }

  @override
  void dispose() {
    super.dispose();
    _tapGestureRecognizer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
            style: TextStyle(color: Color(0xff117689)),
            text: widget.text,
            recognizer: _tapGestureRecognizer));
  }
}

const Duration _kMenuDuration = Duration(milliseconds: 300);

class CommentActionMenuRoute<T> extends PopupRoute<T> {
  final RelativeRect position;

  final void Function() onLike;

  final void Function() onComment;

  final BuildContext showMenuContext;

  CommentActionMenuRoute({
    this.showMenuContext,
    this.position,
    this.onLike,
    this.onComment,
  });

  @override
  Duration get transitionDuration => _kMenuDuration;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => null;

  @override
  final String barrierLabel = "comment_actions";

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: Builder(
        builder: (BuildContext context) {
          var actions = CommentActions(
            popup: true,
            onLike: () {
              this.onLike();
              Navigator.of(context).pop();
            },
            onComment: () {
              Navigator.of(context).pop();
              this.onComment();
            },
          );
          return CustomSingleChildLayout(
            delegate: _PopupMenuRouteLayout(position: position),
            child: actions,
          );
        },
      ),
    );
  }
}

class _PopupMenuRouteLayout extends SingleChildLayoutDelegate {
  _PopupMenuRouteLayout({
    this.position,
  });

  // Rectangle of underlying button, relative to the overlay's dimensions.
  final RelativeRect position;

  // We put the child wherever position specifies, so long as it will fit within
  // the specified parent size padded (inset) by 8. If necessary, we adjust the
  // child's position so that it fits.

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The menu can be at most the size of the overlay minus 8.0 pixels in each
    // direction.
    return BoxConstraints.tight(
        Size(position.right - position.left, position.bottom - position.top));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(position.left, position.top);
  }

  @override
  bool shouldRelayout(_PopupMenuRouteLayout oldDelegate) {
    return position != oldDelegate.position;
  }
}
