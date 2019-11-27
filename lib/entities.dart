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

  //评论者
  final Friend poster;

  //回复评论者
  final Friend replyer;
}

class AudioLink {
  final String cover;

  final String name;

  final String artist;

  final String url;

  AudioLink({this.cover, this.name, this.artist, this.url});
}

class WebPageLink {
  final String cover;

  final String title;

  final String url;

  WebPageLink({this.cover, this.title, this.url});
}

class Moment {
  final Friend friend;

  final String text;

  final int type; //1 纯文本 2：带有图片 3：网页链接 4 ：音频链接

  final AudioLink audioLink;

  final List<String> images;

  final WebPageLink webPageLink;

  final num timestamp;

  final List<Friend> likes;

  final List<Comment> comments;

  Moment({
    this.friend,
    this.text,
    this.type,
    this.audioLink,
    this.timestamp,
    this.images,
    this.webPageLink,
    this.likes,
    this.comments,
  })  : assert(!(type == 4 && audioLink == null),
            "mement type is 4 ，but audio link is null"),
        assert(!(type == 3 && webPageLink == null),
            "mement type is 3 ，but web page link is null"),
        assert(
            !(type == 1 && text == null), "mement type is 1 ，but text is null"),
        assert(!(type == 2 && (images == null || images.length <= 0)),
            "mement type is 2 ，but images is null");
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
