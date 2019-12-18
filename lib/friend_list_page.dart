import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/rapid_positioning.dart';

class FriendListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FriendListPageState();
  }
}

class FriendListPageState extends State<FriendListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: <Widget>[
        ListView.builder(
            itemBuilder: (c, index) {
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
                              image: NetworkImage(
                                  "http://b-ssl.duitang.com/uploads/item/201811/04/20181104074412_wcelx.jpg"))),
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
                                  "梁朝伟",
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
            },
            itemCount: 100),
        Positioned(
          child: Container(
            child: RapidPositioning(
              textStyle: TextStyle(color: Colors.black, fontSize: 11),
              highlightColor: Color.fromARGB(255, 88, 191, 107),
              onChanged: (content, index) {
                print(content);
              },
            ),
            margin: EdgeInsets.only(top: 16, bottom: 16),
          ),
          right: 0,
          top: 10,
          bottom: 10,
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
