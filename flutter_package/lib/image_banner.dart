library flutter_package;

import 'dart:async';

import 'package:flutter/widgets.dart';

// ignore: must_be_immutable
class ImageBanner extends StatefulWidget {
  ImageBanner({Key key, @required this.images}) : super(key: key);

  List<String> images;

  @override
  State<StatefulWidget> createState() {
    return ImageBannerState();
  }
}

class ImageBannerState extends State<ImageBanner> {
  PageController _pageController;
  Timer _timer;
  int _currentPage;

  bool next = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      doScroll(timer);
    });
  }

  void doScroll(Timer timer) {
    if (widget.images.length == 1) {
      return;
    }
    if (_currentPage == widget.images.length - 1) {
      if (next) {
        next = false;
      }
    }
    if (_currentPage == 0) {
      if (!next) {
        next = true;
      }
    }
    if (next) {
      _pageController.nextPage(
          duration: Duration(seconds: 1), curve: Interval(0, 0.5));
    } else {
      _pageController.previousPage(
          duration: Duration(seconds: 1), curve: Interval(0, 0.5));
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var children = widget.images
        .toList()
        .map((image) => Image.network(
              image,
              width: 200,
              height: 200,
            ))
        .toList();
    return Container(
      child: PageView(
        children: children,
        controller: _pageController,
        onPageChanged: (page) => {_currentPage = page},
      ),
    );
  }
}
