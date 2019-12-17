import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/music_player.dart';
import 'package:flutter_app/utils.dart';
import 'package:observable_ui/provider.dart';

import 'app_model.dart';
import 'audio_player.dart';
import 'entities.dart';
import 'memonts_model.dart';

enum CommentAction { like, comment }

class MomentsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MomentsState();
  }
}

class MomentsState extends State<MomentsPage> {
  @override
  Widget build(BuildContext context) {
    var model = ViewModelProvider.of<MomentsModel>(context);
    return Scaffold(
      //捕获回退键
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            CustomScrollView(slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                snap: true,
                stretch: true,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.camera),
                    onPressed: () => {
                      showDialog(
                          context: context,
                          builder: (context) {
                            var body = [
                              Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text("拍摄",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16)),
                                        ),
                                        Align(
                                          child: Text("照片或视频",
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 10)),
                                          alignment: Alignment.centerLeft,
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      height: 1,
                                    ),
                                    Text(
                                      "从相册选择",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16),
                                      textAlign: TextAlign.left,
                                    )
                                  ],
                                ),
                              )
                            ];
                            Widget dialogChild = Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: body,
                            );
                            return Dialog(
                              child: dialogChild,
                              backgroundColor: Colors.transparent,
                            );
                          })
                    },
                  )
                ],
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: Color(0x9988ee00),
                    child: Image.network(
                        "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3129531823,304476160&fm=26&gp=0.jpg"),
                  ),
                  title: Container(
                    child: Text("朋友圈"),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  var item = model.moments[index];
                  switch (item.type) {
                    case 1:
                      return MomentItem(child: Text(item.text), moment: item);
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
//            ListenableBridge(
//              data: [model.showCommentEdit],
//              childBuilder: (context) {
//                return Visibility(
//                  child: Positioned(
//                    left: 0, //widget距离stack左边界距离 ，width = stack宽 - left - right
//                    right: 0,
//                    bottom: 0,
//                    child: Container(
//                      child: Row(
//                        children: <Widget>[
//                          Expanded(
//                              child: Container(
//                            child: EditableText(
//                              controller: TextEditingController(),
//                              focusNode: FocusNode(),
//                              style: TextStyle(),
//                              cursorColor: Color(0xff781929),
//                              backgroundCursorColor: Color(0xff781929),
//                            ),
//                          )),
//                          FlatButton(
//                            child: Text("发送"),
//                            onPressed: () {},
//                          )
//                        ],
//                      ),
//                      color: Color.fromARGB(255, 247, 247, 247),
//                    ),
//                  ),
//                  visible: model.showCommentEdit.value,
//                );
//              },
//            )
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
    return Container(
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
                  this.widget.child,
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
                          showDialog(
                              context: context,
                              builder: (context) {
                                return CommentEditPage();
                              }).then((v) {
                            setState(() {
                              this
                                  .widget
                                  .moment
                                  .comments
                                  .add(Comment(v.content, USER));
                            });
                          });
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
    );
  }

  Future<T> showDialog<T>({
    @required
        BuildContext context,
    bool barrierDismissible = true,
    @Deprecated(
        'Instead of using the "child" argument, return the child from a closure '
        'provided to the "builder" argument. This will ensure that the BuildContext '
        'is appropriate for widgets built in the dialog.')
        Widget child,
    WidgetBuilder builder,
    bool useRootNavigator = true,
  }) {
    assert(child == null || builder == null);
    assert(useRootNavigator != null);
    assert(debugCheckHasMaterialLocalizations(context));

    final ThemeData theme = Theme.of(context, shadowThemeOnly: true);
    return showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        final Widget pageChild = child ?? Builder(builder: builder);
        return SafeArea(
          child: Builder(builder: (BuildContext context) {
            return theme != null
                ? Theme(data: theme, child: pageChild)
                : pageChild;
          }),
        );
      },
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Color(0x01ffffff),
      transitionDuration: const Duration(milliseconds: 150),
      transitionBuilder: _buildMaterialDialogTransitions,
      useRootNavigator: useRootNavigator,
    );
  }

  Widget _buildMaterialDialogTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: child,
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
      color: Color.fromARGB(255, 247, 247, 247),
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

class CommentEditPage extends StatefulWidget {
  @override
  CommentEditState createState() {
    return CommentEditState();
  }
}

class CommentEditState extends State<CommentEditPage> {
  @override
  Widget build(BuildContext context) {
    var dialogChild = IntrinsicHeight(
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 60,
          color: Color.fromARGB(255, 247, 247, 247),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Container(
                child: EditableText(
                  controller: TextEditingController(),
                  focusNode: FocusNode(),
                  style: TextStyle(),
                  cursorColor: Color(0xff781929),
                  backgroundCursorColor: Color(0xff781929),
                ),
              )),
              FlatButton(
                child: Text(
                  "发送",
                  style: TextStyle(color: Color(0xff778fff)),
                ),
                onPressed: () {
                  Navigator.pop(context, CommentEditResult(1, "编辑结果"));
                },
              )
            ],
          ),
        ),
      ),
    );

    return Dialog(
      child: dialogChild,
    );
  }
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
            onPressed: _showPopupMenu)
      ],
    );
  }

  void _showPopupMenu() {
    var box = (placeholderKey.currentContext.findRenderObject() as RenderBox);
    var offset = box.localToGlobal(Offset(0, 0));
    Navigator.of(context, rootNavigator: false).push(PopupMenuRoute(
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

class PopupMenuRoute<T> extends PopupRoute<T> {
  final RelativeRect position;

  final void Function() onLike;

  final void Function() onComment;

  final BuildContext showMenuContext;

  PopupMenuRoute({
    this.showMenuContext,
    this.barrierLabel,
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
  final String barrierLabel;

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
    // If called when the old and new itemSizes have been initialized then
    // we expect them to have the same length because there's no practical
    // way to change length of the items list once the menu has been shown.

    return position != oldDelegate.position;
  }
}

class Dialog extends StatelessWidget {
  /// Creates a dialog.
  ///
  /// Typically used in conjunction with [showDialog].
  const Dialog({
    Key key,
    this.backgroundColor,
    this.elevation,
    this.insetAnimationDuration = const Duration(milliseconds: 100),
    this.insetAnimationCurve = Curves.decelerate,
    this.shape,
    this.child,
  }) : super(key: key);

  /// {@template flutter.material.dialog.backgroundColor}
  /// The background color of the surface of this [Dialog].
  ///
  /// This sets the [Material.color] on this [Dialog]'s [Material].
  ///
  /// If `null`, [ThemeData.cardColor] is used.
  /// {@endtemplate}
  final Color backgroundColor;

  /// {@template flutter.material.dialog.elevation}
  /// The z-coordinate of this [Dialog].
  ///
  /// If null then [DialogTheme.elevation] is used, and if that's null then the
  /// dialog's elevation is 24.0.
  /// {@endtemplate}
  /// {@macro flutter.material.material.elevation}
  final double elevation;

  /// {@template flutter.material.dialog.insetAnimationDuration}
  /// The duration of the animation to show when the system keyboard intrudes
  /// into the space that the dialog is placed in.
  ///
  /// Defaults to 100 milliseconds.
  /// {@endtemplate}
  final Duration insetAnimationDuration;

  /// {@template flutter.material.dialog.insetAnimationCurve}
  /// The curve to use for the animation shown when the system keyboard intrudes
  /// into the space that the dialog is placed in.
  ///
  /// Defaults to [Curves.decelerate].
  /// {@endtemplate}
  final Curve insetAnimationCurve;

  /// {@template flutter.material.dialog.shape}
  /// The shape of this dialog's border.
  ///
  /// Defines the dialog's [Material.shape].
  ///
  /// The default shape is a [RoundedRectangleBorder] with a radius of 2.0.
  /// {@endtemplate}
  final ShapeBorder shape;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  // TODO(johnsonmh): Update default dialog border radius to 4.0 to match material spec.
  static const RoundedRectangleBorder _defaultDialogShape =
      RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)));
  static const double _defaultElevation = 24.0;

  @override
  Widget build(BuildContext context) {
    final DialogTheme dialogTheme = DialogTheme.of(context);
    return MediaQuery.removeViewInsets(
      removeLeft: true,
      removeTop: true,
      removeRight: true,
      removeBottom: true,
      context: context,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 280.0),
          child: Material(
            color: backgroundColor ??
                dialogTheme.backgroundColor ??
                Theme.of(context).dialogBackgroundColor,
            elevation: elevation ?? dialogTheme.elevation ?? _defaultElevation,
            shape: shape ?? dialogTheme.shape ?? _defaultDialogShape,
            type: MaterialType.card,
            child: child,
          ),
        ),
      ),
    );
  }
}
