import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/entities.dart';
import 'package:observable_ui/provider.dart';

import '../../data_source.dart';
import '../../home_model.dart';
import '../../widgets.dart';

class TopMaskLayer extends CustomPainter {
  final double shrinkOffset;

  Paint p = Paint();

  TopMaskLayer(this.shrinkOffset);

  @override
  void paint(Canvas canvas, Size size) {
    //此时三个小点显示，左右两个小点向内聚合
    double lowLine = 200;

    //此时三个点聚合为一个点，该点逐渐变小
    double highLine = 400;

    double maxGap = 20;

    double maxSize = 5;

    double alphaMaxLine = 400;

    int alpha = (255 / (alphaMaxLine) * shrinkOffset).toInt().clamp(0, 255);

    canvas.save();

    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height));

    canvas.drawColor(Color.fromARGB(alpha, 255, 255, 255), BlendMode.srcATop);
    canvas.restore();

    p.color = Color.fromARGB(alpha, 21, 21, 21);

    if (shrinkOffset > lowLine && shrinkOffset < highLine) {
      double gap = maxGap / (lowLine - highLine) * shrinkOffset +
          (maxGap * highLine) / (highLine - lowLine);

      canvas.drawCircle(Offset(size.width / 2 - gap, size.height / 2), 4, p);

      canvas.drawCircle(Offset(size.width / 2, size.height / 2), maxSize, p);

      canvas.drawCircle(Offset(size.width / 2 + gap, size.height / 2), 4, p);
    } else if (shrinkOffset >= 400) {
      canvas.drawCircle(Offset(size.width / 2, size.height / 2),
          17 - 3 / 100 * (shrinkOffset), p);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class BottomMaskLayer extends CustomPainter {
  final double shrinkOffset;

  Paint p = Paint();

  BottomMaskLayer(this.shrinkOffset);

  static const int MAX_ALPHA = 244;

  @override
  void paint(Canvas canvas, Size size) {
    int alpha =
        (-MAX_ALPHA / (300) * shrinkOffset + MAX_ALPHA).toInt().clamp(0, 255);
    canvas.drawColor(Color.fromARGB(alpha, 42, 40, 60), BlendMode.srcATop);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

////需要解决的问题：当SliverList 向下滚动 ，慢慢显示

class RevealHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: SliverRevealPersistentHeaderDelegate(),
    );
  }
}

class SliverRevealPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    double scaleMaxLine = 400;
    double scaleMinLine = 0;
    double scale = (0.5 / (-scaleMaxLine + scaleMinLine) * shrinkOffset +
            (-scaleMaxLine + 0.5 * scaleMinLine) /
                (-scaleMaxLine + scaleMinLine))
        .clamp(0.0, 1.0);
    return CustomPaint(
      child: Transform.scale(
        scale: scale,
        child: Container(
          child: MinProgramHeader(),
        ),
      ),
      painter: BottomMaskLayer(shrinkOffset),
      foregroundPainter: TopMaskLayer(shrinkOffset),
    );
  }

  @override
  double get maxExtent => 600;

  @override
  double get minExtent => 0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class PinnedHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverPinnedPersistentHeaderDelegate(),
    );
  }
}

class SliverPinnedPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      child: Row(
        children: <Widget>[
          Text(
            "微信(130)",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          )
        ],
      ),
    );
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class MinProgramHeader extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MinProgramHeaderState();
  }
}

class OverScrollEndNotification extends Notification {}

const _kOverScrollCriticalRadio = 3 / 2;

class MinProgramHeaderState extends State<MinProgramHeader> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: Text(
            "小程序",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
        ),
        Expanded(
          child: Listener(
            onPointerUp: (e) {
              if (scrollController.position.pixels >
                  (scrollController.position.maxScrollExtent *
                      _kOverScrollCriticalRadio)) {
                OverScrollEndNotification().dispatch(context);
              }
            },
            child: CustomScrollView(
              controller: scrollController,
              physics: BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(2)),
                              color: Color(0x66ffffff)),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.search,
                                color: Color(0x33000000),
                              ),
                              Text(
                                "搜索小程序",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xaaffffff),
                                ),
                              )
                            ],
                          ),
                          margin: EdgeInsets.only(top: 30, bottom: 30),
                          padding: EdgeInsets.only(
                              left: 6, right: 6, top: 8, bottom: 8),
                        ),
                        _buildGridWithLabel("最近使用", minPrograms: MIN_PROGRAMS),
                        SizedBox(
                          height: 10,
                        ),
                        _buildGridWithLabel("最近使用", minPrograms: MIN_PROGRAMS)
                      ],
                    ),
                    margin: EdgeInsets.only(left: 16, right: 16),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildGridWithLabel(String label,
      {List<MinProgram> minPrograms, countForRow = 4}) {
    int rowCount = (minPrograms.length / countForRow).round();
    var rows = <Widget>[
      Align(
        child: Text(
          label,
          style: TextStyle(color: Color(0xffffbdbdbd), fontSize: 12),
        ),
        alignment: Alignment.centerLeft,
      )
    ];

    for (int i = 0; i < rowCount; i++) {
      var widgets = <Widget>[];
      for (int j = countForRow * i;
          j < min(minPrograms.length, countForRow * (i + 1));
          j++) {
        var item = minPrograms[j];

        widgets.add(
          Expanded(
            child: GestureDetector(
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    Container(
                        width: 50,
                        height: 50,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(item.icon),
                        )),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      item.name,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    )
                  ],
                ),
              ),
              onTap: () {
                item.onEnter(context, item);
              },
            ),
          ),
        );
      }

      if (i == rowCount - 1) {
        for (int k = minPrograms.length; k < (rowCount) * countForRow; k++) {
          widgets.add(Spacer());
        }
      }

      rows.add(Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widgets,
        ),
        padding: EdgeInsets.only(top: 4, bottom: 4),
      ));
    }

    return Column(
      children: rows,
    );
  }
}

class ChatListPage extends StatefulWidget {
  ChatListPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChatListPageState();
  }
}

class ChatListPageState extends State<ChatListPage>
    with AutomaticKeepAliveClientMixin {
  ScrollController _scrollController =
      ScrollController(initialScrollOffset: 600);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var model = ViewModelProvider.of<HomeModel>(context);
    return NotificationListener(
      onNotification: (Notification notification) {
        if (notification is ScrollEndNotification &&
            notification.depth == 0 &&
            notification.metrics.pixels <= 600) {
          Future.delayed(Duration(milliseconds: 10), () {
            if (notification.metrics.pixels > 300) {
              _scrollController.animateTo(600,
                  duration: Duration(
                      milliseconds: (notification.metrics.pixels - 300)
                          .clamp(200, 600)
                          .toInt()),
                  curve: Curves.easeOutQuad);
            } else {
              _scrollController.animateTo(0,
                  duration: Duration(
                      milliseconds: (300 - notification.metrics.pixels)
                          .clamp(200, 600)
                          .toInt()),
                  curve: Curves.easeOutQuad);
            }
          });
        } else if (notification is OverScrollEndNotification) {
          _scrollController.animateTo(600,
              duration: Duration(milliseconds: 500), curve: Curves.easeOutQuad);
        }

        return true;
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          RevealHeader(),
          PinnedHeader(),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return _buildChatItem(context, model.chatItems[index]);
            }, childCount: model.chatItems.length),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, item) {
    return GestureDetector(
      child: Container(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: <Widget>[
              Subscript(
                //圆角头像
                content: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      image: DecorationImage(
                          image: NetworkImage(
                              "http://b-ssl.duitang.com/uploads/item/201811/04/20181104074412_wcelx.jpg"))),
                ),
                subscript: Container(
                  width: 16,
                  height: 16,
                  alignment: Alignment.center,
                  child: Text(
                    "11",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 8),
                  ),
                  decoration:
                      ShapeDecoration(shape: CircleBorder(), color: Colors.red),
                ),
                width: 60,
                height: 60,
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: Container(
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(child: Text("梁朝伟")),
                          Text("早上10:00")
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text("暂无最近消息"),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          )),
      onTap: () {
        if (item is SubscriptionMsgBoxEntrance) {
          Navigator.of(context).pushNamed("/subscription_box");
          return;
        }

        Navigator.of(context).pushNamed("/chat_detail");
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
