

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/page/tiktok/user_profile.dart';
import 'package:flutter_app/page/tiktok/video_feed.dart';
import 'package:observable_ui/provider.dart';

class TikTokPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TikTokPageState();
  }
}

class TikTokPageState extends State<TikTokPage> {
  double _tabBarLeft = 0;

  double _tabBarIndicatorRadio = 0;

  PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return ViewModelProvider(
      viewModel: VideoFeedModel(),
      child: Scaffold(
        body: Container(
          color: Colors.black,
          child: NotificationListener(
            child: Stack(
              children: <Widget>[
                PageView(
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    VideoFeedsScreen(),
                    VideoFeedsScreen(),
                    UserProfileScreen()
                  ],
                ),
                Positioned(
                  child: SafeArea(
                    child: Center(
                      child: TabBar(
                        radio: _tabBarIndicatorRadio,
                        onSelected: (pos) {
                          _pageController.animateToPage(pos,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.ease);
                        },
                      ),
                    ),
                  ),
                  left: _tabBarLeft,
                  right: -_tabBarLeft,
                  top: 10,
                ),
              ],
            ),
            onNotification: (ScrollNotification notification) {
              if (notification.depth == 0 &&
                  notification is ScrollUpdateNotification &&
                  notification.metrics is PageMetrics) {
                if (notification.metrics.pixels >=
                    notification.metrics.viewportDimension) {
                  var delta = (notification.metrics.pixels -
                      notification.metrics.viewportDimension);
                  setState(() {
                    _tabBarLeft = -delta;
                  });
                } else {
                  var radio = (notification.metrics.pixels /
                      notification.metrics.viewportDimension)
                      .clamp(0, 1);
                  setState(() {
                    _tabBarIndicatorRadio = radio;
                  });
                }
              }
              return true;
            },
          ),
        ),
      ),
    );
  }
}

class TabBar extends StatefulWidget {
  final double radio;

  final void Function(int pos) onSelected;

  const TabBar({Key key, this.radio, this.onSelected}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TabBarState();
  }
}

class TabBarState extends State<TabBar> {
  static const TAB_WIDTH = 70.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              child: Container(
                child: Text(
                  "关注",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                width: TAB_WIDTH,
              ),
              onTap: () {
                widget.onSelected(0);
              },
            ),
            GestureDetector(
              child: Container(
                child: Text(
                  "推荐",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                width: TAB_WIDTH,
              ),
              onTap: () {
                widget.onSelected(1);
              },
            )
          ],
        ),
        SizedBox(
          height: 6,
        ),
        SizedBox(
          width: TAB_WIDTH * 2,
          height: 2,
          child: Align(
            alignment: Alignment(2 * widget.radio - 1, 0),
            child: Container(
              width: TAB_WIDTH,
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Container(
                decoration: BoxDecoration(color: Colors.white),
              ),
            ),
          ),
        )
      ],
    );
  }
}
