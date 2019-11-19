import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/entities.dart';
import 'package:observable_ui/core.dart';
import 'package:observable_ui/widgets.dart';
import 'package:provider/provider.dart';

import 'HomeModel.dart';

class HomePage extends StatelessWidget {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<HomeModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("微信"),
      ),
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          ChatListPage(),
          ChatListPage(),
          DiscoveryPage(),
          ChatListPage(),
        ],
      ),
      bottomNavigationBar: ObservableBridge(
        data: [model.currentIndex],
        childBuilder: (context) {
          return BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                title: Text('聊天'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business),
                title: Text('联系人'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                title: Text('发现'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                title: Text('我'),
              ),
            ],
            currentIndex: model.currentIndex.value,
            selectedItemColor: Colors.amber[800],
            onTap: (value) {
              model.currentIndex.value = value;
              _pageController.jumpToPage(value);
            },
          );
        },
      ),
    );
  }
}

class ChatListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var model = Provider.of<HomeModel>(context);
    return ListViewEx.builder(
        items: model.chatItems,
        itemBuilder: (context, item) {
          return _buildChatItem(context, item);
        });
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

//实现角标
class Subscript extends StatelessWidget {
  final double width;

  final double height;

  final Widget content;

  final Widget subscript;

  const Subscript(
      {Key key, this.width, this.height, this.content, this.subscript})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
            child: this.content,
            width: this.width,
            height: this.height,
            alignment: Alignment.center),
        Container(
            child: this.subscript,
            width: this.width,
            height: this.height,
            alignment: Alignment.topRight)
      ],
    );
  }
}

class CustomPaint2 extends CustomPaint {}

class RenderCustomPaint2 extends RenderCustomPaint {
  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
  }
}
