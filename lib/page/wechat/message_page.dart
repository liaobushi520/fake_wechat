import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/bottom_sheet.dart' as AutoBottomSheet;
import 'package:observable_ui/provider.dart';

import '../../chat_model.dart';
import '../../data_source.dart';
import '../../entities.dart';
import '../../home_model.dart';
import '../../widgets.dart';
import 'chat_detail_page.dart';

class MessagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MessagePageState();
  }
}

const _kMinSheetSize=0.15;

class MessagePageState extends State<MessagePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  GlobalKey revealHeaderKey = GlobalKey();

  GlobalKey dotsAnimation = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var model = ViewModelProvider.of<HomeModel>(context);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return RepaintBoundary(
            child: Stack(
              children: <Widget>[
                NotificationListener(
                  onNotification: (notification) {
                    print(notification);
                    if (notification
                        is AutoBottomSheet.DraggableScrollableNotification) {
                      RevealHeaderState revealHeaderState =
                          (revealHeaderKey.currentState as RevealHeaderState);
                      revealHeaderState.update(notification.extent);

                      DotsAnimationState dotsAnimationState =
                          (dotsAnimation.currentState as DotsAnimationState);
                      dotsAnimationState.update(notification.extent);
                    }
                    return true;
                  },
                  child: AutoBottomSheet.DraggableScrollableSheet(
                    minChildSize: _kMinSheetSize,
                    initialChildSize: 1,
                    builder: (context, scrollControl) {
                      return Column(
                        children: <Widget>[
                          _buildHeader(),
                          Expanded(
                            child: ListView.builder(
                                controller: scrollControl,
                                itemCount: model.chatItems.length,
                                itemBuilder: (context, index) {
                                  return _buildChatItem(
                                      context, model.chatItems[index]);
                                }),
                          )
                        ],
                      );
                    },
                  ),
                ),
                RevealHeader(revealHeaderKey, constraints.maxHeight),
                DotsAnimation(dotsAnimation, constraints.maxHeight),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 237, 237, 23),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      child: Row(
        children: <Widget>[
          Text(
            "微信(130)",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

  Widget _buildChatItem(BuildContext context, Entrance item) {
    return GestureDetector(
      child: Container(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Subscript(
                //圆角头像
                content: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      image: DecorationImage(
                          image: NetworkImage(item.icon), fit: BoxFit.cover)),
                ),
                subscript: Container(
                  width: 16,
                  height: 16,
                  alignment: Alignment.center,
                  child: Text(
                    "${item.unreadCount}",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 8),
                  ),
                  decoration:
                      ShapeDecoration(shape: CircleBorder(), color: Colors.red),
                ),
                width: 54,
                height: 54,
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
                          Expanded(
                              child: Text(
                            item.name,
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          )),
                          Text(
                            item.recentMessage?.timestamp != null
                                ? "${item.recentMessage.timestamp}"
                                : "",
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 185, 185, 185)),
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              item.recentMessage == null
                                  ? "暂无最近消息"
                                  : item.recentMessage.text,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 185, 185, 185)),
                            ),
                          )
                        ],
                      ),
                      Divider(
                        height: 1,
                      )
                    ],
                  ),
                ),
              )
            ],
          )),
      onTap: () {
        if (item.name == "订阅号消息") {
          Navigator.of(context).pushNamed("/subscription_box");
          return;
        }

        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ViewModelProvider(
            viewModel: ChatModel(item.extra as Friend),
            child: ChatDetailPage(),
          );
        }));
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}


class RevealHeader extends StatefulWidget {
  final double stackHeight;

  @override
  State<StatefulWidget> createState() {
    return RevealHeaderState();
  }
  const RevealHeader(Key key, this.stackHeight) : super(key: key);
}


class RevealHeaderState extends State<RevealHeader> {

  double offset = 1;

  bool expand = false;

  void update(double offset) {
    setState(() {
      if (offset == 1) {
        expand = false;
      }
      if (offset == _kMinSheetSize) {
        expand = true;
      }
      this.offset = offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!expand) {
      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: widget.stackHeight - (1 - offset) * widget.stackHeight,
        child: CustomPaint(
          child: Transform.scale(
            scale: 1 - offset + _kMinSheetSize,
            child: MinProgramHeader(),
          ),
          painter: BottomMaskLayer(offset),
        ),
      );
    }

    return Positioned(
      top: -(1-_kMinSheetSize) * widget.stackHeight -
          widget.stackHeight * offset +
          widget.stackHeight,
      height: (1-_kMinSheetSize) * widget.stackHeight,
      left: 0,
      right: 0,
      child: CustomPaint(
        child: MinProgramHeader(),
        painter: BottomMaskLayer(offset),
      ),
    );
  }
}


class DotsAnimation extends StatefulWidget {

  final double stackHeight;

  const DotsAnimation(Key key, this.stackHeight) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DotsAnimationState();
  }
}

class DotsAnimationState extends State<DotsAnimation> {

  double offset = 1;

  void update(double offset) {
    setState(() {
      this.offset = offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: widget.stackHeight - (1 - offset) * widget.stackHeight,
      child: CustomPaint(
        foregroundPainter: TopMaskLayer(offset),
      ),
    );
  }
}

class TopMaskLayer extends CustomPainter {
  final double shrinkOffset;

  Paint p = Paint();

  TopMaskLayer(this.shrinkOffset);

  @override
  void paint(Canvas canvas, Size size) {
    //此时三个小点显示，左右两个小点向内聚合
    double lowLine = 0.6;

    //此时三个点聚合为一个点，该点逐渐变小
    double highLine = 0.8;

    double maxGap = 20;

    double maxSize = 5;

    int alpha=255;

    double bgLowLine=0.8;

    if(shrinkOffset>=bgLowLine){
      alpha=255;
    }else{
      alpha = (255 * (1/(bgLowLine-_kMinSheetSize)*shrinkOffset-1/(bgLowLine-_kMinSheetSize)*_kMinSheetSize)).toInt().clamp(0, 255);
    }
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height));
    canvas.drawColor(Color.fromARGB(alpha, 255, 255, 255), BlendMode.srcATop);
    canvas.restore();

    int dotAlpha=255;
    if(shrinkOffset<highLine){
      dotAlpha=(255 *(0.5/(highLine-lowLine)*shrinkOffset+1-0.5/(highLine-lowLine))).toInt();
    }
    print(dotAlpha);

    p.color = Color.fromARGB(dotAlpha, 21, 21, 21);
    if (shrinkOffset > lowLine && shrinkOffset < highLine) {
      double gap = maxGap / (lowLine - highLine) * shrinkOffset +
          (maxGap * highLine) / (highLine - lowLine);

      canvas.drawCircle(Offset(size.width / 2 - gap, size.height / 2), 4, p);
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), maxSize, p);
      canvas.drawCircle(Offset(size.width / 2 + gap, size.height / 2), 4, p);

    } else if (shrinkOffset >= highLine) {
      canvas.drawCircle(Offset(size.width / 2, size.height / 2),
          maxSize * (-5 * shrinkOffset + 5), p);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class BottomMaskLayer extends CustomPainter {

  final double offset;

  Paint p = Paint();

  BottomMaskLayer(this.offset);

  static const int MAX_ALPHA = 255;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.drawColor(
        Color.fromARGB(((1 - this.offset) * MAX_ALPHA).toInt(), 66, 64, 88),
        BlendMode.srcATop);
    canvas.restore();
  }

  @override
  bool shouldRepaint(BottomMaskLayer oldDelegate) {
    return oldDelegate.offset != offset;
  }
}


class OverScrollEndNotification extends Notification {}

const _kOverScrollCriticalRadio = 3 / 2;

class MinProgramHeader extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MinProgramHeaderState();
  }
}

class MinProgramHeaderState extends State<MinProgramHeader> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: Text(
            "小程序",
            style: TextStyle(color: Colors.white, fontSize: 16),
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
                        _buildGridWithLabel("最近使用", minPrograms: [...MIN_PROGRAMS,...MIN_PROGRAMS,...MIN_PROGRAMS]),
                        SizedBox(
                          height: 10,
                        ),
                        _buildGridWithLabel("我的小程序", minPrograms: [...MIN_PROGRAMS,...MIN_PROGRAMS,...MIN_PROGRAMS])
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
          style: TextStyle(color: Color(0xffffbdbdbd), fontSize: 10),
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
                        width: 46,
                        height: 46,
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
