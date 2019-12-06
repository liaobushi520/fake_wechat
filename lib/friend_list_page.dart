import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/rapid_positioning.dart';

class FriendListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FriendListPageState();
  }
}

class FriendListPageState extends State<FriendListPage> {
  final ScrollController _scrollController = TrackingScrollController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ListView.builder(
            controller: _scrollController,
            itemBuilder: (c, index) {
              return Container(
                width: 100,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          color: Colors.orange,
                          image: DecorationImage(
                              image: NetworkImage(
                                  "http://b-ssl.duitang.com/uploads/item/201811/04/20181104074412_wcelx.jpg"))),
                    )
                  ],
                ),
              );
            },
            itemCount: 100),
        Positioned(
          child: Container(
            child: RapidPositioning(
              backgroundColor: Color(0xff781112),
              onChanged: (content, index) {
                print(content);
              },
            ),
            margin: EdgeInsets.only(top: 16, bottom: 16),
          ),
          right: 0,
          top: 0,
          bottom: 0,
        )
      ],
    );
  }
}
