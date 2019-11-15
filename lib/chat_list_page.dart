import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:observable_ui/widgets.dart';
import 'package:provider/provider.dart';

import 'HomeModel.dart';

class HomePage extends StatelessWidget {
  HomePage({Key key}) : super(key: key);

  PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>(
      child: _HomePage(),
      builder: (context) => HomeModel(),
    );
  }
}

class _HomePage extends StatelessWidget {
  PageController _pageController = PageController();

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
          ChatListPage(),
          TagLayout(),
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

class TagLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 1.0, color: Color(0xFFFFDFDFDF)),
              left: BorderSide(width: 1.0, color: Color(0xFFFFDFDFDF)),
              right: BorderSide(width: 1.0, color: Color(0xFFFF7F7F7F)),
              bottom: BorderSide(width: 1.0, color: Color(0xFFFF7F7F7F)),
            ),
            color: Color(0xFFBFBFBF),
          ),
          child: Text("艺术采光好或或或军扩或扩或过错扩或军扩军或扩军扩绿过，环境铁浮屠统一"),
        ),
        Text("电影"),
        Text("文学"),
      ],
    );
  }
}

class ChatListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(itemBuilder: (context, index) {
      return Text("111${index}");
    });
  }
}

class CustomPaint2 extends CustomPaint {}

class RenderCustomPaint2 extends RenderCustomPaint {
  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
  }
}
