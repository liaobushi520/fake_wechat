import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:observable_ui/core.dart';
import 'package:observable_ui/widgets.dart';

class SubscriptionBoxPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("订阅号消息"),
      ),
      body: Center(
          child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildOftenRead();
                }
                return _buildSubscriptionCard();
              })),
    );
  }

  Widget _buildOftenRead() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          child: Text("常读的订阅号"),
          margin: EdgeInsets.only(left: 12, top: 14, bottom: 0),
        ),
        Container(
          alignment: Alignment.center,
          child: ListViewEx.builder(
            items: ObservableList(initValue: ["", "", "", "", "", "", "", ""]),
            itemBuilder: (context, item) {
              return Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(),
                    Row(
                      children: <Widget>[Text("环球时报")],
                    )
                  ],
                ),
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
              );
            },
            scrollDirection: Axis.horizontal,
          ),
          height: 80,
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard() {
    return Card(
      margin: EdgeInsets.only(left: 8, top: 0, bottom: 16, right: 8),
      child: Container(
        child: Column(
          children: <Widget>[
            //卡片头
            Container(
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                        "http://b-ssl.duitang.com/uploads/item/201811/04/20181104074412_wcelx.jpg"),
                  ),
                  Text("央视新闻"),
                  Spacer(),
                  Text("一分钟前")
                ],
              ),
              padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
            ),
            Stack(
              children: <Widget>[
                Image.network(
                  "https://pics2.baidu.com/feed/8601a18b87d6277fbc988af78a6ada35eb24fccb.jpeg?token=9a42458de603221ff28fc45ea0ac197a&s=65925B9E4C71469CC6B171D003005035",
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                ),
                Positioned(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "两位朋友读过",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text("谋杀李伯现场的两人被抓", style: TextStyle(color: Colors.white))
                    ],
                  ),
                  left: 10,
                  bottom: 10,
                )
              ],
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "【关注】全身五成烧伤，至今昏迷不醒..李伯家人：要撑住",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Image.network(
                    "http://b-ssl.duitang.com/uploads/item/201811/04/20181104074412_wcelx.jpg",
                    width: 60,
                    height: 60,
                  )
                ],
              ),
              padding: EdgeInsets.fromLTRB(12, 16, 12, 16),
            ),
            //卡片尾
            Row(
              children: <Widget>[
                Text("余下两篇"),
                Spacer(),
                Icon(Icons.arrow_drop_down)
              ],
            )
          ],
        ),
      ),
    );
  }
}
