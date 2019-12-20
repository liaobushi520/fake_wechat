import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/widgets.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UserProfileScreenState();
  }
}

class UserProfileScreenState extends State with SingleTickerProviderStateMixin {
  final List<Tab> myTabs = <Tab>[
    Tab(text: 'LEFT'),
    Tab(text: 'RIGHT'),
  ];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              color: Color.fromARGB(255, 22, 24, 35),
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: Color(0x9988ee00),
                    child: Image.network(
                      "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3129531823,304476160&fm=26&gp=0.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  child: Column(
                    children: <Widget>[TopInfoSection(), BottomInfoSection()],
                  ),
                ),
              ),
              PinnedHeader(
                child: TabBar(
                  controller: _tabController,
                  tabs: myTabs,
                ),
              ),
              SliverFillRemaining(
                  child: TabBarView(
                controller: _tabController,
                children: myTabs.map((Tab tab) {
                  return Center(
                    child: VideoGrid(),
                  );
                }).toList(),
              )),
            ],
          )
        ],
      ),
    );
  }
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

  static const TOTAL_WIDTH = 200.0;

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
              color: _follow ? Colors.black : Color.fromARGB(255, 234, 67, 89),
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
              color: Color.fromARGB(255, 37, 39, 47),
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

class TopInfoSectionState extends State with SingleTickerProviderStateMixin {
  bool _expand = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        AnimatedContainer(
          decoration: BoxDecoration(
              border: Border.all(width: 4),
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: NetworkImage(
                      "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3129531823,304476160&fm=26&gp=0.jpg"),
                  fit: BoxFit.cover)),
          width: _expand ? 80 : 40,
          height: _expand ? 80 : 40,
          duration: Duration(milliseconds: 500),
        ),
        FollowAnimation(),
        FlatButton(
          child: Text(
            ">",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            setState(() {
              _expand = !_expand;
            });
          },
        )
      ],
    );
  }
}

class MiddleInfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "明星拍摄东方热巴",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 28,
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
        padding: EdgeInsets.only(left: 10),
      ),
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
        padding: EdgeInsets.only(left: 10),
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
    return GridView.builder(
        itemCount: 10,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            childAspectRatio: 3.0 / 4.0),
        itemBuilder: (context, index) {
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
        });
  }
}

class PinnedHeader extends StatelessWidget {
  final Widget child;

  const PinnedHeader({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverPinnedPersistentHeaderDelegate(child),
    );
  }
}

class SliverPinnedPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  final Widget child;

  SliverPinnedPersistentHeaderDelegate(this.child);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 30;

  @override
  double get minExtent => 30;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
