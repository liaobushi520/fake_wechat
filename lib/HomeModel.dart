import 'package:flutter/material.dart';
import 'package:flutter_app/entities.dart';
import 'package:observable_ui/core.dart';

class HomeModel extends ChangeNotifier {
  ObservableValue<int> currentIndex = ObservableValue(0);

  ObservableList<Entrance> chatItems = ObservableList(initValue: [
    ChatEntrance(
        friend: Friend(
            name: "梁朝伟",
            avatar:
                "http://b-ssl.duitang.com/uploads/item/201811/04/20181104074412_wcelx.jpg"),
        unreadCount: 10,
        recentMessage: Message(0, text: "我是好人")),
    SubscriptionMsgBoxEntrance(0, Message(0, text: "我是好人"))
  ]);
}
