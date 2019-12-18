import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:observable_ui/core.dart';
import 'package:observable_ui/provider.dart';

import 'home_model.dart';
import 'page/wechat/chat_list_page.dart';
import 'page/wechat/discovery_page.dart';
import 'page/wechat/friend_list_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<HomePage> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    var model = ViewModelProvider.of<HomeModel>(context);

    return ObservableBridge(
      data: [model.currentIndex],
      childBuilder: (context) {
        return Scaffold(
          body: SafeArea(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                model.currentIndex.value = index;
              },
              children: <Widget>[
                ChatListPage(),
                FriendListPage(),
                DiscoveryPage(),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
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
            ],
            currentIndex: model.currentIndex.value,
            selectedItemColor: Color.fromARGB(255, 88, 191, 107),
            onTap: (value) {
              model.currentIndex.value = value;
              _pageController.jumpToPage(value);
            },
          ),
        );
      },
    );
  }
}
