import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/page/tiktok/video_feed.dart';

import 'entities.dart';

const List<Friend> FRIENDS = [
  Friend(
      name: "梁朝伟",
      avatar:
          "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576668990899&di=0d6e27b2fe5b27501d6d2dc3533c5e84&imgtype=0&src=http%3A%2F%2Fpic4.zhimg.com%2F914971f36da5e150cb0a61b171f095eb_b.jpg"),
  Friend(
      name: "长泽雅美",
      avatar:
          "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=3607243162,3473478855&fm=26&gp=0.jpg"),
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
        builder: (context) => VideoFeedPage(),
      ),
    );
  }),
  MinProgram("QQ音乐", "http://pic.962.net/up/2016-4/2016418917511892.png",
      (context, item) {}),
  MinProgram("豆瓣", "http://pic2.orsoon.com/2016/0914/20160914112533658.png",
      (context, item) {}),
  MinProgram(
      "今日头条",
      "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576669446398&di=1cb9308cd9645a4f434bba43d66056ea&imgtype=0&src=http%3A%2F%2Fimg1.sooshong.com%2Fpics%2F201606%2F4%2F201664223036205.jpg",
      (context, item) {}),
];
