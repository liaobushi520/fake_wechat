import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/entities.dart';
import 'package:observable_ui/provider.dart';

import 'HomeModel.dart';
import 'widgets.dart';

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
    print(shrinkOffset);

    return Stack(
      children: <Widget>[
        Positioned(
          left: shrinkOffset,
          right: shrinkOffset,
          top: 0,
          bottom: 0,
          child: Opacity(
            opacity: 1.0 - shrinkOffset / 200,
            child: Container(
              child: _buildMinProgramPage(),
              color: Colors.orange,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildMinProgramPage() {
    return Column(
      children: <Widget>[
        Text("小程序"),
        _buildGridWithLabel("最近使用", minPrograms: ["", "", ""]),
        _buildGridWithLabel("最近使用", minPrograms: ["", "", ""])
      ],
    );
  }

  Widget _buildGridWithLabel(String label, {List minPrograms}) {
    int rowCount = (minPrograms.length / 3).round();
    var rows = <Widget>[Text(label)];
    for (int i = 0; i <= rowCount; i++) {
      var widgets = <Widget>[];
      for (int j = 3 * i; j < min(minPrograms.length, 3 * (i + 1)); j++) {
        widgets.add(Expanded(
            child: Padding(
                padding: EdgeInsets.all(4),
                child: CircleAvatar(
                  child: Image.network(
                      "http://b-ssl.duitang.com/uploads/item/201811/04/20181104074412_wcelx.jpg"),
                ))));
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

  @override
  double get maxExtent => 200;

  @override
  double get minExtent => 0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

//class RevealHeader extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return SliverToRevealBoxAdapter(
//      child: Container(
//        child: Center(child: Text("Reveal Header")),
//        color: Colors.blueAccent,
//        height: 300,
//      ),
//    );
//  }
//}
//
//class SliverToRevealBoxAdapter extends SingleChildRenderObjectWidget {
//  const SliverToRevealBoxAdapter({
//    Key key,
//    Widget child,
//  }) : super(key: key, child: child);
//
//  @override
//  RenderObject createRenderObject(BuildContext context) {
//    return RenderSliverToRevealBoxAdapter();
//  }
//}
//
//class RenderSliverToRevealBoxAdapter extends RenderSliverSingleBoxAdapter {
//  @override
//  void performLayout() {
//    //  print(constraints);
//    child.layout(constraints.asBoxConstraints(), parentUsesSize: true);
//
//    //  print(constraints.scrollOffset);
//
//    double layoutExtent = (child.size.height - constraints.scrollOffset)
//        .clamp(0.0, child.size.height);
//
//    print("height ${child.size.height}");
//    geometry = SliverGeometry(
//        scrollExtent: child.size.height,
//        paintExtent: layoutExtent,
//        maxPaintExtent: child.size.height,
//        layoutExtent: layoutExtent
//        //paintOrigin: -400
//        //paintOrigin: -child.size.height + constraints.scrollOffset
//        );
//
//    setChildParentData(child, constraints, geometry);
//  }
//}

////需要解决的问题：当SliverList 向上滚动时，不滚动 ，向下滚动时跟随SliverList滚动

//class PersistentHeader extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return SliverToBoxAdapter2(
//      child: Container(
//        child: Row(
//          children: <Widget>[
//            Text("微信(130)"),
//            Spacer(),
//            IconButton(
//              icon: Icon(Icons.search),
//              onPressed: () {},
//            )
//          ],
//        ),
//        color: Colors.red,
//      ),
//    );
//  }
//}
//
//class SliverToBoxAdapter2 extends SingleChildRenderObjectWidget {
//  const SliverToBoxAdapter2({
//    Key key,
//    Widget child,
//  }) : super(key: key, child: child);
//
//  @override
//  RenderObject createRenderObject(BuildContext context) {
//    return RenderSliverToBoxAdapter2();
//  }
//}
//
//class RenderSliverToBoxAdapter2 extends RenderSliverSingleBoxAdapter {
//  @override
//  void performLayout() {
//    child.layout(constraints.asBoxConstraints(), parentUsesSize: true);
//
//    double layoutExtent = (child.size.height - constraints.scrollOffset)
//        .clamp(0.0, child.size.height);
//    print(constraints);
//
//    geometry = SliverGeometry(
//        scrollExtent: 0.0,
//        paintExtent: child.size.height,
//        maxScrollObstructionExtent: child.size.height,
//        hasVisualOverflow: true,
//        paintOrigin: constraints.scrollOffset,
//        layoutExtent: layoutExtent,
//        maxPaintExtent: child.size.height);
//
//    setChildParentData(child, constraints, geometry);
//  }
//}

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
      child: Row(
        children: <Widget>[
          Text("微信(130)"),
          Spacer(),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          )
        ],
      ),
      color: Colors.red,
    );
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

class ChatListPage extends StatelessWidget {
  final ScrollController scrollController;

  const ChatListPage({Key key, this.scrollController}) : super(key: key);

//  @override
//  Widget build(BuildContext context) {
//    var model = ViewModelProvider.of<HomeModel>(context);
//    return ListViewEx.builder(
//        controller: scrollController,
//        items: model.chatItems,
//        itemBuilder: (context, item) {
//          return _buildChatItem(context, item);
//        });
//  }

  @override
  Widget build(BuildContext context) {
    var model = ViewModelProvider.of<HomeModel>(context);

    return SizedBox(
      child: CustomScrollView(
        controller: ScrollController(initialScrollOffset: 300),
        // reverse: true,
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
      height: 200,
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
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      color: Colors.orange,
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
}

class DiscoveryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          child: Container(
            child: Row(
              children: <Widget>[
                Icon(Icons.camera),
                SizedBox(
                  width: 8,
                ),
                Text("朋友圈"),
                Spacer(),
                Icon(Icons.chevron_right)
              ],
            ),
            padding: EdgeInsets.all(8),
          ),
          onTap: () {
            Navigator.of(context).pushNamed("/moments");
          },
        )
      ],
    );
  }
}
