import 'package:flutter/cupertino.dart';
import 'package:flutter_app/entities.dart';
import 'package:observable_ui/core2.dart';

const USER = Friend(
    name: "廖布斯",
    avatar:
        "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=1236308033,3321919462&fm=26&gp=0.jpg");

const DEFAULT_FRIENDS = [
  Friend(
      name: "梁朝伟",
      avatar:
          "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1575338510&di=2c4ccaf42a260b8463d8744ff1184da1&imgtype=jpg&er=1&src=http%3A%2F%2Fy2.ifengimg.com%2Fa13eecb1dba8cce3%2F2014%2F0925%2Frdn_542371e0404c5.png"),
  Friend(
      name: "刘德华",
      avatar:
          "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1575338736&di=59553e505a6fd221c24ae06c4629506e&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.ifeng.com%2Fres%2F200811%2F1126_500745.jpg")
];

class MomentsModel {
  ListenableList<Moment> moments = ListenableList(initValue: [
    Moment(
        text: "我喜欢的一首歌",
        friend: DEFAULT_FRIENDS[0],
        type: 4,
        timestamp: 1000123,
        audioLink: AudioLink(
            cover:
                "https://pic.xiami.net/images/album/img45/6845/1681181434526239.jpg?x-oss-process=image/resize,limit_0,s_480,m_fill/quality,q_80",
            name: "回忆沙漠",
            artist: "杨宗纬",
            url:
                "https://s128.xiami.net/319/7319/33091/2079859_1504591944341.mp3?ccode=xiami_web_web&expire=86400&duration=240&psid=1f7d861ad34121847e1baff291f794b5&ups_client_netip=180.168.34.146&ups_ts=1576208553&ups_userid=0&utid=gRndEezL1FUCAcuc24qbR1GW&vid=2079859&fn=2079859_1504591944341.mp3&vkey=B9d39482218a406823a91a2d0d4d04694"),
        likes: [],
        comments: []),
    Moment(
        text: "我今天很开心",
        friend: DEFAULT_FRIENDS[1],
        type: 1,
        timestamp: 1000123,
        likes: [],
        comments: []),
    Moment(
      text: "看看这个新闻",
      friend: DEFAULT_FRIENDS[1],
      type: 3,
      timestamp: 1000123,
      likes: [],
      webPageLink: WebPageLink(
          title: "网易绝情踢员工",
          cover:
              "http://pics1.baidu.com/feed/91529822720e0cf39dbaefe79e693c1abe09aa16.jpeg?token=7ef31617682291d1ad08c5b64621db06&s=BD9A7F9540224AAEBA0828ED03003033",
          url:
              "http://baijiahao.baidu.com/s?id=1651222227934364431&wfr=spider&for=pc"),
    ),
    Moment(
      text: "看看这个新闻",
      friend: DEFAULT_FRIENDS[1],
      type: 3,
      timestamp: 1000123,
      likes: [],
      webPageLink: WebPageLink(
          title: "网易绝情踢员工",
          cover:
              "http://pics1.baidu.com/feed/91529822720e0cf39dbaefe79e693c1abe09aa16.jpeg?token=7ef31617682291d1ad08c5b64621db06&s=BD9A7F9540224AAEBA0828ED03003033",
          url:
              "http://baijiahao.baidu.com/s?id=1651222227934364431&wfr=spider&for=pc"),
    ),
    Moment(
      text: "看看这个新闻",
      friend: DEFAULT_FRIENDS[1],
      type: 3,
      timestamp: 1000123,
      likes: [],
      webPageLink: WebPageLink(
          title: "网易绝情踢员工",
          cover:
              "http://pics1.baidu.com/feed/91529822720e0cf39dbaefe79e693c1abe09aa16.jpeg?token=7ef31617682291d1ad08c5b64621db06&s=BD9A7F9540224AAEBA0828ED03003033",
          url:
              "http://baijiahao.baidu.com/s?id=1651222227934364431&wfr=spider&for=pc"),
    ),
    Moment(
        text: "我今天很开心",
        friend: DEFAULT_FRIENDS[0],
        type: 2,
        timestamp: 1000123,
        images: [
          "http://b-ssl.duitang.com/uploads/item/201811/04/20181104074412_wcelx.jpg",
          "http://b-ssl.duitang.com/uploads/item/201811/04/20181104074412_wcelx.jpg",
          "http://b-ssl.duitang.com/uploads/item/201811/04/20181104074412_wcelx.jpg"
        ],
        likes: [],
        comments: [
          Comment("好样的", DEFAULT_FRIENDS[1]),
          Comment("你是个人才", DEFAULT_FRIENDS[1]),
          Comment("你才是个人才", DEFAULT_FRIENDS[0], replyer: DEFAULT_FRIENDS[1]),
        ])
  ]);

  ValueNotifier<bool> showCommentEdit = ValueNotifier(false);
}
