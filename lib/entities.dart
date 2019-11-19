import 'dart:io';

class Item {}

class Message implements Item {
  const Message(this.type, {this.file, this.text, this.url, this.duration});

  final int type; //0 文本  1 图片  2 声音 3 红包

  final File file;

  final String text;

  final String url;

  final num duration;
}

class Marker implements Item {
  const Marker(this.type, this.text);

  final int type;

  final String text;
}

class Friend {
  const Friend({this.name, this.avatar});

  final String name;

  final String avatar;
}

class Comment {
  const Comment(this.text, this.poster, {this.replyer});

  final String text;

  final Friend poster;

  final Friend replyer;
}

class Entrance {
  final int unreadCount;

  final Message recentMessage;

  const Entrance(this.unreadCount, this.recentMessage);
}

class SubscriptionMsgBoxEntrance extends Entrance {
  const SubscriptionMsgBoxEntrance(int unreadCount, Message recentMessage)
      : super(unreadCount, recentMessage);
}

class ChatEntrance extends Entrance {
  final Friend friend;

  const ChatEntrance({this.friend, unreadCount, recentMessage})
      : super(unreadCount, recentMessage);
}
