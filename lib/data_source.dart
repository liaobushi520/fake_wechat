import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/page/douban/douban_page.dart';
import 'package:flutter_app/page/reader/read_page.dart';
import 'package:flutter_app/page/tiktok/video_feed.dart';

import 'entities.dart';
import 'page/tiktok/main.dart';

const USER = Friend(
    name: "廖布斯",
    avatar:
        "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=1236308033,3321919462&fm=26&gp=0.jpg",
    momentsCover:
        "https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1577093270&di=2bd3f20670a6b468b680664dda873c63&src=http://b-ssl.duitang.com/uploads/item/201709/21/20170921103932_vC4NR.jpeg");

const List<Friend> FRIENDS = [
  Friend(
      name: "梁朝伟",
      avatar:
          "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576668990899&di=0d6e27b2fe5b27501d6d2dc3533c5e84&imgtype=0&src=http%3A%2F%2Fpic4.zhimg.com%2F914971f36da5e150cb0a61b171f095eb_b.jpg"),
  Friend(
      name: "长泽雅美",
      avatar:
          "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=3607243162,3473478855&fm=26&gp=0.jpg",
      momentsCover:
          "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3129531823,304476160&fm=26&gp=0.jpg"),
  Friend(
      name: "刘德华",
      avatar:
          "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=3846959827,4200674399&fm=26&gp=0.jpg"),
  Friend(
      name: "周华健",
      avatar:
          "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576668751759&di=c3c34453866761c90a240068950593c1&imgtype=0&src=http%3A%2F%2Fimg.5nd.com%2F250%2FPhoto%2Fsinger%2F1%2F3039.jpg"),
  Friend(
      name: "宇多田光",
      avatar:
          "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576668699017&di=6a35e609baa061158e4a526fe3a070e2&imgtype=0&src=http%3A%2F%2Fs9.rr.itc.cn%2Fr%2FwapChange%2F201611_24_12%2Fa2hqy75949515717503.jpeg"),
  Friend(
      name: "仓木麻衣",
      avatar:
          "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576669076568&di=0936f7a7ec4a3bbc7d4d10ff53b689c9&imgtype=0&src=http%3A%2F%2Fpicm.bbzhi.com%2Fmingxingbizhi%2Fcangmumayikurakimai%2Fstar_starjp_198158_m.jpg"),
  Friend(
      name: "小栗旬",
      avatar:
          "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576669097850&di=55770837e42cd4c2fbbd5c1d6664ac17&imgtype=0&src=http%3A%2F%2Fztd00.photos.bdimg.com%2Fztd%2Fw%3D700%3Bq%3D50%2Fsign%3D2188551bb83533faf5b6912e98e88c22%2F562c11dfa9ec8a135b778bf5fe03918fa0ecc0b2.jpg"),
  Friend(
      name: "金城武",
      avatar:
          "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=282634885,4205940362&fm=26&gp=0.jpg"),
  Friend(
      name: "张卫健",
      avatar:
          "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1577263926&di=07c43b047293b8e95f691cbdaa84344f&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.mp.sohu.com%2Fq_mini%2Cc_zoom%2Cw_640%2Fupload%2F20170721%2F54544c99d89a47c685ef461b5bd85a7c_th.jpg"),
  Friend(
      name: "赵本山",
      avatar:
          "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=2655657748,3681886583&fm=26&gp=0.jpg"),
  Friend(
      name: "新垣结衣",
      avatar:
          "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1577264341&di=e3a569bc386d0eae544a929852597e15&imgtype=jpg&er=1&src=http%3A%2F%2Fdingyue.ws.126.net%2FhkMGnsbJGT1EkIr6zHmPS0QnlEoUxS2VCenK0BBQhDA7i1550203810262.jpg"),
  Friend(
      name: "滨崎步",
      avatar:
          "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576669772412&di=67f33543d8384c9770028b66916d5032&imgtype=0&src=http%3A%2F%2Fbigtu.eastday.com%2Fimg%2F201211%2F06%2F89%2F8398021580555610609.jpg"),
  Friend(
      name: "林青霞",
      avatar:
          "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576669741416&di=bab7afbbd07a94779b3800380624bb6a&imgtype=0&src=http%3A%2F%2Fn1.itc.cn%2Fimg8%2Fwb%2Frecom%2F2017%2F01%2F13%2F148429027077417546.JPEG"),
];

final MIN_PROGRAMS = [
  MinProgram("抖音",
      "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576472833976&di=bfc3b95448eb89321f4e25ea0fbf2054&imgtype=0&src=http%3A%2F%2Fhbimg.huabanimg.com%2Ff2b2ad85a548a22049f10f90cf32dd8cd9f79b0c90c0-gbkg5j_fw658",
      (context, item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TikTokPage(),
      ),
    );
  }),
  MinProgram("QQ音乐", "http://pic.962.net/up/2016-4/2016418917511892.png",
      (context, item) {}),
  MinProgram("豆瓣", "http://pic.962.net/up/2016-4/2016418917511892.png",
      (context, item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoubanPage(),
      ),
    );
  }),
  MinProgram(
      "今日头条",
      "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576669446398&di=1cb9308cd9645a4f434bba43d66056ea&imgtype=0&src=http%3A%2F%2Fimg1.sooshong.com%2Fpics%2F201606%2F4%2F201664223036205.jpg",

      (context, item) {}),
  MinProgram("微信阅读",
      "https://rescdn.qqmail.com/node/wr/wrpage/style/images/independent/favicon/favicon_48h.png",
      (context, item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadPage(),
      ),
    );
  }),
];
final VIDEO_FEEDS = [
  VideoFeed(
      url:
          'https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4',
      userName: "lzj",
      text: "好好玩",
      voiceSourceText: "@廖布斯创作的原声-廖布斯"),
  VideoFeed(
      url:
          'https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4',
      userName: "lh",
      text: "好好玩吗",
      voiceSourceText: "@周星驰创作的原声-周星驰")
];

final CHAT_ENTRANCES = [
  FriendEntrance(
      extra: FRIENDS[0],
      unreadCount: 3,
      recentMessage: Message(0, text: "一起拍电影吧", timestamp: 1000000000)),
  FriendEntrance(
      extra: FRIENDS[1],
      unreadCount: 10,
      recentMessage: Message(0, text: "我要来中国了", timestamp: 100000000)),
  FriendEntrance(
      extra: FRIENDS[2],
      unreadCount: 10,
      recentMessage: Message(0, text: "有什么电影推荐啊?")),
  FriendEntrance(
      extra: FRIENDS[3],
      unreadCount: 10,
      recentMessage: Message(0, text: "我是天王杀手，ok？")),
  FriendEntrance(
      extra: FRIENDS[4],
      unreadCount: 10,
      recentMessage: Message(0, text: "你做喜欢我的什么歌？")),
  FriendEntrance(
      extra: FRIENDS[5],
      unreadCount: 10,
      recentMessage: Message(0, text: "周末一起吃饭吧")),
  FriendEntrance(
      extra: FRIENDS[6],
      unreadCount: 10,
      recentMessage: Message(0, text: "我很帅的啊")),
  FriendEntrance(
      extra: FRIENDS[7],
      unreadCount: 10,
      recentMessage: Message(0, text: "我可以是日本人啊！")),
  FriendEntrance(
      extra: FRIENDS[8],
      unreadCount: 10,
      recentMessage: Message(0, text: "周末一起吃个饭吧")),
  FriendEntrance(
      extra: FRIENDS[9],
      unreadCount: 10,
      recentMessage: Message(0, text: "啥时来看二人转？")),
  FriendEntrance(
      extra: FRIENDS[10],
      unreadCount: 10,
      recentMessage: Message(0, text: "你喜欢我的什么呢？")),
  FriendEntrance(
      extra: FRIENDS[11],
      unreadCount: 10,
      recentMessage: Message(0, text: "我出新歌了，来听听吧！")),
  FriendEntrance(
      extra: FRIENDS[12],
      unreadCount: 10,
      recentMessage: Message(0, text: "还记得我的电影吗？")),
];

final TikTokComments = [
  TiTokComment(
      Comment(
        "你是好样的",
        FRIENDS[0],
        likeCount: 1000,
      ),
      subComments: [
        Comment(
          "你才是好样的",
          FRIENDS[1],
          likeCount: 1111,
        ),
        Comment(
          "你最棒",
          FRIENDS[2],
          likeCount: 1133,
        )
      ]),
  TiTokComment(
      Comment(
        "你是好样的",
        FRIENDS[2],
        likeCount: 100,
      ),
      subComments: [
        Comment(
          "你才是好样的",
          FRIENDS[3],
          likeCount: 111,
        )
      ]),
  TiTokComment(
      Comment(
        "你是好样的",
        FRIENDS[0],
        likeCount: 10,
      ),
      subComments: [
        Comment(
          "你才是好样的",
          FRIENDS[2],
          likeCount: 11,
        )
      ]),
  TiTokComment(
      Comment(
        "你是好样的",
        FRIENDS[3],
        likeCount: 110,
      ),
      subComments: [
        Comment(
          "你才是好样的",
          FRIENDS[4],
          likeCount: 11,
        )
      ]),
  TiTokComment(
      Comment(
        "你是好样的",
        FRIENDS[0],
        likeCount: 10,
      ),
      subComments: [
        Comment(
          "你才是好样的",
          FRIENDS[2],
          likeCount: 11,
        )
      ]),
  TiTokComment(
      Comment(
        "你是好样的",
        FRIENDS[3],
        likeCount: 110,
      ),
      subComments: [
        Comment(
          "你才是好样的",
          FRIENDS[4],
          likeCount: 11,
        )
      ]),
  TiTokComment(
      Comment(
        "你是好样的",
        FRIENDS[0],
        likeCount: 10,
      ),
      subComments: [
        Comment(
          "你才是好样的",
          FRIENDS[2],
          likeCount: 11,
        )
      ]),
  TiTokComment(
      Comment(
        "你是好样的",
        FRIENDS[3],
        likeCount: 110,
      ),
      subComments: [
        Comment(
          "你才是好样的",
          FRIENDS[4],
          likeCount: 11,
        )
      ])
];

final MOMENTS = [
  Moment(
      text: "我喜欢的一首歌",
      friend: FRIENDS[0],
      type: 4,
      timestamp: 1000123,
      audioLink: AudioLink(
          cover:
              "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1577271400447&di=35b8834221385b63377f2bdbf64b41d4&imgtype=0&src=http%3A%2F%2Fcdn.music.migu.cn%2Fpicture%2F2018%2F0412%2F1800%2FARTL1610171034331187.jpg",
          name: "回忆沙漠",
          artist: "杨宗纬",
          url:
              "https://s128.xiami.net/319/7319/33091/2079859_1504591944341.mp3?ccode=xiami_web_web&expire=86400&duration=240&psid=5d941ef50b2cde1e54c20939cb7827c9&ups_client_netip=180.168.34.146&ups_ts=1577245143&ups_userid=0&utid=gRndEezL1FUCAcuc24qbR1GW&vid=2079859&fn=2079859_1504591944341.mp3&vkey=B31b0177eaa1a08dc891fa635b67134c8"),
      likes: [],
      comments: []),
  Moment(
      text: "分享一首好听的歌",
      friend: FRIENDS[2],
      type: 4,
      timestamp: 1000123,
      audioLink: AudioLink(
          cover:
              "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1577873709&di=97b1734cb9ad28ad9b619901610d74ce&imgtype=jpg&er=1&src=http%3A%2F%2Fcdnmusic.migu.cn%2Fpicture%2F2017%2F1109%2F0716%2FAL1609221019437724.jpg",
          name: "你不是真正的快乐",
          artist: "五月天",
          url:"https://s128.xiami.net/308/2308/12362/152042_1592377026108_6224.mp3?ccode=xiami_web_web&expire=86400&duration=280&psid=02e1c36d691411325f3913aefe724469&ups_client_netip=116.233.173.222&ups_ts=1601197062&ups_userid=0&utid=EH8FFQJPcUwCAbSrci4s0dCj&vid=152042&fn=152042_1592377026108_6224.mp3&vkey=Baf736aa59beec55945d39c5cf7abb0bf"),
       likes: [],
      comments: []),
  Moment(
      text: "我今天很开心",
      friend: FRIENDS[5],
      type: 1,
      timestamp: 1000123,
      likes: [],
      comments: []),
  Moment(
    text: "看看这个新闻",
    friend: FRIENDS[3],
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
    friend: FRIENDS[4],
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
    friend: FRIENDS[1],
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
      friend: FRIENDS[0],
      type: 2,
      timestamp: 1000123,
      images: [
        "http://b-ssl.duitang.com/uploads/item/201811/04/20181104074412_wcelx.jpg",
        "http://b-ssl.duitang.com/uploads/item/201811/04/20181104074412_wcelx.jpg",
        "http://b-ssl.duitang.com/uploads/item/201811/04/20181104074412_wcelx.jpg"
      ],
      likes: [],
      comments: [
        Comment("好样的", FRIENDS[1]),
        Comment("你是个人才", FRIENDS[1]),
        Comment("你才是个人才", FRIENDS[0], replyer: FRIENDS[1]),
      ])
];
