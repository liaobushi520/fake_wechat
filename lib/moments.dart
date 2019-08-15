import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'entities.dart';

class MomentsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MomentsState();
  }
}

class MomentsState extends State<MomentsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: [
      SliverAppBar(
        expandedHeight: 200,
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            color: Color(0x9988ee00),
            child: Image.network(
                "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3129531823,304476160&fm=26&gp=0.jpg"),
          ),
          title: Container(
            child: Text("朋友圈"),
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index % 2 == 0) {
            return buildMomentItem(buildImageGrid2([
              "http://b-ssl.duitang.com/uploads/item/201811/04/20181104074412_wcelx.jpg",
              "http://b-ssl.duitang.com/uploads/item/201811/04/20181104074412_wcelx.jpg"
            ]));
          }
          return buildMomentItem(Text("$index"));
        }, childCount: 1000),
      )
    ]));
  }

  Widget buildImageGrid(List<String> images) {
    return Container(
      child: GridView.builder(
          shrinkWrap: true,
          itemCount: 4,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemBuilder: (context, index) {
            return Image.network(
                "http://b-ssl.duitang.com/uploads/item/201811/04/20181104074412_wcelx.jpg");
          }),
    );
  }

  Widget buildImageGrid2(List<String> images) {
    int rowCount = (images.length / 3).round();
    var rows = <Row>[];
    for (int i = 0; i <= rowCount; i++) {
      var widgets = <Widget>[];
      for (int j = 3 * i; j < min(images.length, 3 * (i + 1)); j++) {
        widgets.add(Expanded(
            child: Padding(
                padding: EdgeInsets.all(4), child: Image.network(images[j]))));
      }
      rows.add(Row(
        children: widgets,
      ));
    }

    return Container(
        child: Column(
      children: rows,
    ));
  }

  Widget buildMomentItem(Widget content) {
    return Container(
      padding: EdgeInsets.only(left: 12, top: 8, right: 12, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            color: Color(0x77889911),
            child: Icon(Icons.pregnant_woman),
          ),
          Expanded(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("廖布斯"),
                  content,
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text("10分钟前"),
                      ),
                      Icon(Icons.more)
                    ],
                  ),
                  buildComments([
                    Friend(name: "李四"),
                    Friend(name: "李四"),
                    Friend(name: "李四"),
                    Friend(name: "张三"),
                    Friend(name: "李四"),
                    Friend(name: "李四"),
                    Friend(name: "李四"),
                    Friend(name: "李四"),
                    Friend(name: "李四"),
                    Friend(name: "张三"),
                    Friend(name: "李四"),
                    Friend(name: "李四"),
                    Friend(name: "李四")
                  ], [
                    Comment("聊不死", Friend(name: "李八"),
                        replyer: Friend(name: "利旧"))
                  ])
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildComments(List<Friend> likeFriends, List<Comment> comments) {
    var commentSpans = comments
        .map((comment) => Container(
                child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(children: [
                TextSpan(
                    text: comment.poster.name,
                    style: TextStyle(color: Color(0xff770011))),
                if (comment.replyer != null)
                  TextSpan(
                    children: [
                      TextSpan(text: "回复"),
                      TextSpan(
                          text: comment.replyer.name,
                          style: TextStyle(color: Color(0xff770011)))
                    ],
                  ),
                TextSpan(text: comment.text)
              ]),
            )))
        .toList();
    return Container(
      color: Color(0x55bdbdbd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildLikes(likeFriends),
          Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: commentSpans,
          )
        ],
      ),
    );
  }

  Widget buildLikes(List<Friend> likeFriends) {
    final likeSpans =
        likeFriends.map((friend) => TextSpan(text: friend.name)).toList();

    return Row(
      children: <Widget>[
        Icon(
          Icons.favorite,
          size: 16,
        ),
        Expanded(
          child: RichText(text: TextSpan(children: likeSpans)),
        )
      ],
    );
  }
}

typedef TapCallback<T> = void Function(T extras);

class LinkText<T> extends StatefulWidget {
  const LinkText(this.text, {this.extra, this.onTap});

  final String text;

  final T extra;

  final TapCallback<T> onTap;

  @override
  State<StatefulWidget> createState() {
    return LinkTextState();
  }
}

class LinkTextState extends State<LinkText> {
  TapGestureRecognizer _tapGestureRecognizer;

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer = TapGestureRecognizer();
    _tapGestureRecognizer.onTap = () => widget.onTap(widget.extra);
  }

  @override
  void dispose() {
    super.dispose();
    _tapGestureRecognizer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
            style: TextStyle(color: Color(0xff117689)),
            text: widget.text,
            recognizer: _tapGestureRecognizer));
  }
}
