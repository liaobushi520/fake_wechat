import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/rapid_positioning.dart';

import '../../data_source.dart';
import '../../entities.dart';

List items = [
  "B",
  FRIENDS[11],
  "C",
  FRIENDS[1],
  FRIENDS[5],
  "L",
  FRIENDS[0],
  FRIENDS[2],
  FRIENDS[12],
  "J",
  FRIENDS[7],
  "X",
  FRIENDS[6],
  FRIENDS[10],
  "Y",
  FRIENDS[4],
  "Z",
  FRIENDS[3],
  FRIENDS[8],
  FRIENDS[9],
  FRIENDS.length
];

class _Item<T> {
  final T data;

  final void Function(BuildContext buildContext, T data) build;

  _Item(this.data, this.build);
}

Widget _buildTotalFriendCount(BuildContext buildContext, int data) {
  return Container(
    alignment: Alignment.center,
    height: 40,
    padding: EdgeInsets.only(top: 10, bottom: 10),
    child: Text(
      "$data位联系人",
      style: TextStyle(fontSize: 16, color: Color(0xffbdbdbd)),
    ),
  );
}

const _kLetterIndicatorHeight = 30;

const _kFriendItemHeight = 56;

Widget _buildLetterIndicator(BuildContext buildContext, String data) {
  return Container(
    height: 30,
    child:
        Text("$data", style: TextStyle(fontSize: 10, color: Color(0xff000000))),
    color: Color(0x88bdbdbd),
    padding: EdgeInsets.only(top: 10, bottom: 10, left: 14),
  );
}

Widget _buildFriendItem(BuildContext buildContext, Friend data) {
  return Container(
    padding: EdgeInsets.only(left: 14, top: 4, bottom: 4),
    child: Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(6)),
              image: DecorationImage(
                  image: NetworkImage(data.avatar), fit: BoxFit.cover)),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: SizedBox(
            height: 48,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Align(
                    child: Text(
                      data.name,
                      style: TextStyle(fontSize: 15),
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 1,
                  child: Container(
                    color: Color(0x55bdbdbd),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    ),
  );
}

class FriendListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FriendListPageState();
  }
}

class FriendListPageState extends State<FriendListPage>
    with AutomaticKeepAliveClientMixin {
  ScrollController _controller = ScrollController();

  GlobalKey listViewKey = GlobalKey();

  double _contactTotalHeight = 0.0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    for (Object item in items) {
      if (item is Friend) {
        _contactTotalHeight += _kFriendItemHeight;
      } else if (item is String) {
        _contactTotalHeight += _kLetterIndicatorHeight;
      }
    }

    return Container(
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          ListView.builder(
              key: listViewKey,
              controller: _controller,
              itemBuilder: (context, index) {
                var item = items[index];
                if (item is String) {
                  return _buildLetterIndicator(context, item);
                } else if (item is Friend) {
                  return _buildFriendItem(context, item);
                }
                return _buildTotalFriendCount(context, item);
              },
              itemCount: items.length),
          Positioned(
            child: Container(
              child: RapidPositioning(
                textStyle: TextStyle(color: Colors.black, fontSize: 11),
                highlightColor: Color.fromARGB(255, 88, 191, 107),
                onChanged: (content, index) {
                  double offset = 0.0;
                  double listViewHeight = listViewKey.currentContext.size.height;
                  for (Object item in items) {
                    if (item is Friend) {
                      offset += _kFriendItemHeight;
                    } else if (item is String) {
                      if (item == content) {
                        if (_contactTotalHeight <= listViewHeight) {
                          _controller.jumpTo(0);
                        } else {
                          if (_contactTotalHeight - offset < listViewHeight) {
                            _controller
                                .jumpTo((_contactTotalHeight - listViewHeight));
                          } else {
                            _controller.jumpTo(offset);
                          }
                        }
                        return;
                      } else {
                        offset += _kLetterIndicatorHeight;
                      }
                    }
                  }
                },
              ),
              margin: EdgeInsets.only(top: 16, bottom: 16),
            ),
            right: 0,
            top: 10,
            bottom: 10,
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
