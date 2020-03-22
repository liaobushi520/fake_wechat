import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/widgets.dart';

const Color _kTikTokBackgroundColor = Color.fromARGB(255, 22, 24, 35);

class UserProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UserProfileScreenState();
  }
}

class CompleteFoldingNotification extends Notification {
  final bool completeFolding;

  const CompleteFoldingNotification(this.completeFolding);
}

class TikTokHeader extends StatefulWidget {
  final TabController tabController;

  final List<Tab> tabs;

  const TikTokHeader({Key key, this.tabController, this.tabs})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TikTokHeaderState();
  }
}

class TikTokHeaderState extends State<TikTokHeader> {

  Color backgroundColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (notification) {
        if (notification is CompleteFoldingNotification) {
          SchedulerBinding.instance.addPostFrameCallback((timestamp) {
            setState(() {
              backgroundColor = notification.completeFolding
                  ? _kTikTokBackgroundColor
                  : Colors.transparent;
            });
          });
        }
        return true;
      },
      child: _TikTokHeader(
        delegate: SliverChildListDelegate([
          Column(
            children: <Widget>[
              Image.network(
                "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3129531823,304476160&fm=26&gp=0.jpg",
                fit: BoxFit.cover,
              ),
              TopInfoSection(),
              BottomInfoSection()
            ],
          ),
          Container(
            child: Row(
              children: <Widget>[
                Container(
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                  alignment: Alignment.center,
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x66000000),
                  ),
                ),
                Spacer(),
                Text(
                  "中国新闻网",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(
                  width: 10,
                ),
                RaisedButton(
                  onPressed: () {},
                  child: Text(
                    "关注",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  color: BUTTON_ACCENT_COLOR,
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            padding: EdgeInsets.only(left: 16),
            color: backgroundColor,
          ),
          TabBar(
            indicatorColor: Color.fromARGB(255, 243, 206, 74),
            controller: widget.tabController,
            tabs: widget.tabs,
          )
        ]),
      ),
    );
  }
}

class _TikTokHeader extends SliverMultiBoxAdaptorWidget {
  const _TikTokHeader({
    Key key,
    @required SliverChildDelegate delegate,
  }) : super(key: key, delegate: delegate);

  @override
  RenderSliverMultiBoxAdaptor createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element =
        context as SliverMultiBoxAdaptorElement;
    return TikTokHeaderRenderSliver(childManager: element);
  }
}

class TikTokHeaderRenderSliver extends RenderSliverMultiBoxAdaptor {
  TikTokHeaderRenderSliver({
    @required RenderSliverBoxChildManager childManager,
  }) : super(childManager: childManager);

  bool _completeFolding = false;

  @override
  void performLayout() {
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);

    if (firstChild == null) {
      addInitialChild();
      firstChild.layout(constraints.asBoxConstraints().tighten(),
          parentUsesSize: true);

      var secondChild = insertAndLayoutChild(
          constraints.asBoxConstraints().tighten(),
          after: firstChild,
          parentUsesSize: true);

      final SliverMultiBoxAdaptorParentData secondChildParentData =
          secondChild.parentData as SliverMultiBoxAdaptorParentData;
      secondChildParentData.layoutOffset = 0.0;

      var thirdChild = insertAndLayoutChild(
          constraints.asBoxConstraints().tighten(),
          after: secondChild,
          parentUsesSize: true);
      final SliverMultiBoxAdaptorParentData thirdChildParentData =
          thirdChild.parentData as SliverMultiBoxAdaptorParentData;
      thirdChildParentData.layoutOffset = firstChild.size.height;
    } else {
      firstChild.layout(constraints.asBoxConstraints().tighten(),
          parentUsesSize: true);

      final SliverMultiBoxAdaptorParentData firstChildParentData =
          firstChild.parentData as SliverMultiBoxAdaptorParentData;
      firstChildParentData.layoutOffset = 0.0;

      var secondChild = childAfter(firstChild);
      var thirdChild = childAfter(secondChild);

      final SliverMultiBoxAdaptorParentData secondChildParentData =
          secondChild.parentData as SliverMultiBoxAdaptorParentData;
      secondChildParentData.layoutOffset = constraints.scrollOffset;

      final SliverMultiBoxAdaptorParentData thirdChildParentData =
          thirdChild.parentData as SliverMultiBoxAdaptorParentData;

      thirdChildParentData.layoutOffset =
          max(secondChild.size.height, firstChild.size.height);
    }
    var secondChild = childAfter(firstChild);
    var thirdChild = childAfter(secondChild);

    var paintExtent = max(
        firstChild.size.height +
            thirdChild.size.height -
            constraints.scrollOffset,
        secondChild.size.height + thirdChild.size.height);

    var element = childManager as SliverMultiBoxAdaptorElement;
    if(secondChild.size.height + thirdChild.size.height ==
        paintExtent.round()){
      if( _completeFolding == false){
        _completeFolding = true;
        CompleteFoldingNotification(true).dispatch(element);
      }
    }else{
      if(_completeFolding == true){
        _completeFolding = false;
        CompleteFoldingNotification(false).dispatch(element);
      }
    }

    geometry = SliverGeometry(
        scrollExtent: firstChild.size.height - secondChild.size.height,
        maxPaintExtent: firstChild.size.height + thirdChild.size.height,
        paintExtent: paintExtent);
    childManager.didFinishLayout();
  }
}

class UserProfileScreenState extends State with SingleTickerProviderStateMixin , AutomaticKeepAliveClientMixin{
  final List<Tab> _tabs = <Tab>[
    Tab(
      child: Padding(
        child: Text(
          "作品100",
          style: TextStyle(fontSize: 16),
        ),
        padding: EdgeInsets.only(top: 8, bottom: 4),
      ),
    ),
    Tab(
      child: Padding(
        child: Text(
          "作品100",
          style: TextStyle(fontSize: 16),
        ),
        padding: EdgeInsets.only(top: 8, bottom: 4),
      ),
    ),
  ];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _tabs.length);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
          body: Container(
        color: _kTikTokBackgroundColor,
        constraints: BoxConstraints.expand(),
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              TikTokHeader(
                tabController: _tabController,
                tabs: _tabs,
              )
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: _tabs.map((Tab tab) {
              return Builder(
                builder: (context) {
                  return CustomScrollView(
                    slivers: <Widget>[
                      VideoGrid(),
                    ],
                  );
                },
              );
            }).toList(),
          ),
        ),
      )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class TopInfoSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TopInfoSectionState();
  }
}

class FollowAnimation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FollowAnimationState();
  }
}

class FollowAnimationState extends State with SingleTickerProviderStateMixin {
  bool _follow = false;

  AnimationController _controller;

  Animation leftAnimation, rightAnimation;

  static const TOTAL_WIDTH = 180.0;

  static const MESSAGE_BTN_WIDTH = 60.0;

  static const GAP = 4.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    var rectTween = RelativeRectTween(
        begin: RelativeRect.fromLTRB(0, 0, 0, 0),
        end: RelativeRect.fromLTRB(0, 0, MESSAGE_BTN_WIDTH + GAP, 0));
    var rectTween1 = RelativeRectTween(
        begin: RelativeRect.fromLTRB(TOTAL_WIDTH, 0, -MESSAGE_BTN_WIDTH, 0),
        end: RelativeRect.fromLTRB(TOTAL_WIDTH - MESSAGE_BTN_WIDTH, 0, 0, 0));

    leftAnimation = rectTween.animate(_controller);
    rightAnimation = rectTween1.animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: TOTAL_WIDTH,
      height: 40,
      child: Stack(
        children: <Widget>[
          PositionedTransition(
            rect: leftAnimation,
            child: RaisedButton(
              color: _follow ? BUTTON_BACKGROUND_COLOR : BUTTON_ACCENT_COLOR,
              child: _follow
                  ? Text("取消关注", style: TextStyle(color: Colors.white))
                  : Text(
                      "+关注",
                      style: TextStyle(color: Colors.white),
                    ),
              onPressed: () {
                setState(() {
                  if (_follow) {
                    _controller.reverse();
                  } else {
                    _controller.forward();
                  }
                  _follow = !_follow;
                });
              },
            ),
          ),
          PositionedTransition(
            rect: rightAnimation,
            child: RaisedButton(
              child: Icon(
                Icons.message,
                color: Colors.white,
              ),
              color: BUTTON_BACKGROUND_COLOR,
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

const BUTTON_BACKGROUND_COLOR = Color.fromARGB(255, 58, 58, 67);

const BUTTON_ACCENT_COLOR = Color.fromARGB(255, 234, 67, 89);

class TopInfoSectionState extends State with SingleTickerProviderStateMixin {
  bool _expand = false;

  static const MAX_AVATAR_SIZE = 100.0;

  static const MIN_AVATAR_SIZE = 40.0;

  AnimationController _controller;

  Animation topAnimation, bottomAnimation, rotationAnimation;

  static const MAX_HEIGHT = 255.0;

  static const MIN_HEIGHT = 70.0;

  static const ANIMATION_DURATION = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: ANIMATION_DURATION,
        lowerBound: 0.0,
        upperBound: .5);

    var topTween = RelativeRectTween(
        begin: RelativeRect.fromLTRB(0, 0, 0, 0),
        end: RelativeRect.fromLTRB(0, -MIN_HEIGHT, 0, MAX_HEIGHT));
    var bottomTween = RelativeRectTween(
        begin: RelativeRect.fromLTRB(0, MIN_HEIGHT, 0, -MAX_HEIGHT),
        end: RelativeRect.fromLTRB(0, 0, 0, 0));

    var rotationTween = Tween(begin: 0.0, end: 0.5);

    rotationAnimation = rotationTween.animate(_controller);
    topAnimation = topTween.animate(_controller);
    bottomAnimation = bottomTween.animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              AnimatedContainer(
                decoration: BoxDecoration(
                    border: Border.all(width: 1),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage(
                            "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3129531823,304476160&fm=26&gp=0.jpg"),
                        fit: BoxFit.cover)),
                width: !_expand ? MAX_AVATAR_SIZE : MIN_AVATAR_SIZE,
                height: !_expand ? MAX_AVATAR_SIZE : MIN_AVATAR_SIZE,
                duration: ANIMATION_DURATION,
              ),
              Spacer(),
              FollowAnimation(),
              RawMaterialButton(
                child: RotationTransition(
                  turns: _controller,
                  child: Icon(
                    Icons.change_history,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                fillColor:
                    !_expand ? BUTTON_BACKGROUND_COLOR : BUTTON_ACCENT_COLOR,
                constraints: BoxConstraints.tightFor(width: 40, height: 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2))),
                onPressed: () {
                  setState(() {
                    if (_expand) {
                      _controller.reverse();
                    } else {
                      _controller.forward();
                    }
                    _expand = !_expand;
                  });
                },
              ),
            ],
          ),
          AnimatedContainer(
            duration: ANIMATION_DURATION,
            height: _expand ? MAX_HEIGHT : MIN_HEIGHT,
            child: Stack(
              children: <Widget>[
                PositionedTransition(
                  rect: topAnimation,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "明星拍摄东方热巴",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          "抖音号：1900011",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
                PositionedTransition(
                  child: RecommendAccounts(),
                  rect: bottomAnimation,
                )
              ],
            ),
          )
        ],
      ),
      padding: EdgeInsets.only(left: 10, right: 10),
    );
  }
}

class BottomInfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      child: Padding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Divider(
              color: Color.fromARGB(255, 66, 66, 66),
            ),
            Text(
              "每天更新明星实时动态哦",
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              children: <Widget>[
                Container(
                  padding:
                      EdgeInsets.only(left: 2, right: 2, top: 1, bottom: 1),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.pregnant_woman,
                        color: Color.fromARGB(255, 234, 67, 89),
                        size: 13,
                      ),
                      Text("21岁",
                          style: TextStyle(
                              color: Color.fromARGB(255, 123, 124, 129))),
                    ],
                  ),
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 37, 39, 47),
                      borderRadius: BorderRadius.circular(2)),
                ),
                SizedBox(
                  width: 4,
                ),
                Container(
                  padding:
                      EdgeInsets.only(left: 2, right: 2, top: 1, bottom: 1),
                  child: Text(
                    "北京电影学院",
                    style: TextStyle(color: Color.fromARGB(255, 123, 124, 129)),
                  ),
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 37, 39, 47),
                      borderRadius: BorderRadius.circular(2)),
                )
              ],
            ),
            SizedBox(
              height: 12,
            ),
            Row(
              children: <Widget>[
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: "2.3W",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: "获赞", style: TextStyle(color: Color(0xffbdbdbd)))
                  ]),
                ),
                SizedBox(
                  width: 4,
                ),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: "2.3W",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    TextSpan(text: "关注")
                  ]),
                ),
                SizedBox(
                  width: 4,
                ),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: "2.3W",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    TextSpan(text: "粉丝")
                  ]),
                )
              ],
            )
          ],
        ),
        padding: EdgeInsets.only(left: 10, right: 10),
      ),
      alignment: Alignment.centerLeft,
    );
  }
}

class RecommendAccounts extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RecommendAccountsState();
  }
}

class RecommendAccountsState extends State<RecommendAccounts> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 6,
                ),
                Expanded(
                  child: Text("你可能感兴趣的人",
                      style: TextStyle(color: Color(0xffbdbdbd), fontSize: 12)),
                ),
                Text("查看更多",
                    style: TextStyle(color: Color(0xffbdbdbd), fontSize: 12)),
                SizedBox(
                  width: 6,
                ),
              ],
            ),
            padding: EdgeInsets.only(top: 6, bottom: 6),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 30,
                itemBuilder: (context, index) {
                  return Card(
                    color: Color.fromARGB(255, 37, 39, 47),
                    child: Stack(
                      children: <Widget>[
                        Padding(
                          child: Column(
                            children: <Widget>[
                              buildCircleImage(
                                  70,
                                  NetworkImage(
                                      "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=1236308033,3321919462&fm=26&gp=0.jpg")),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                "少女刘杀鸡",
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(
                                height: 14,
                              ),
                              Text("可能感兴趣的人",
                                  style: TextStyle(
                                      color: Color(0xffbdbdbd), fontSize: 12)),
                              Spacer(),
                              RaisedButton(
                                child: Text(
                                  "     关注    ",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {},
                                color: Color.fromARGB(255, 234, 67, 89),
                                padding: EdgeInsets.only(left: 20, right: 20),
                              )
                            ],
                          ),
                          padding: EdgeInsets.only(
                              left: 8, right: 8, top: 10, bottom: 4),
                        ),
                        Positioned(
                          right: 3,
                          top: 3,
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 10,
                          ),
                        )
                      ],
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }
}

class VideoGrid extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return VideoGridState();
  }
}

class VideoGridState extends State<VideoGrid> {
  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
          childAspectRatio: 3.0 / 4.0),
      delegate: SliverChildBuilderDelegate((BuildContext context, index) {
        return Stack(
          children: <Widget>[
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Image.network(
                "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=1236308033,3321919462&fm=26&gp=0.jpg",
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 5,
              bottom: 5,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    size: 12,
                  ),
                  Text(
                    "1000",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  )
                ],
              ),
            )
          ],
        );
      }, childCount: 20),
    );
  }
}

class SliverPinnedPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  final Widget child;

  final double maxExtent;

  final double minExtent;

  SliverPinnedPersistentHeaderDelegate(
      this.child, this.maxExtent, this.minExtent);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
