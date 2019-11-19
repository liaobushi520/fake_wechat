import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/SubscriptionBoxModel.dart';
import 'package:flutter_app/chat_detail_page.dart';
import 'package:flutter_app/memonts_model.dart';
import 'package:flutter_app/moments_page.dart';
import 'package:flutter_app/subscription_message_page.dart';
import 'package:provider/provider.dart';

import 'HomeModel.dart';
import 'chat_list_page.dart';
import 'chat_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
          backgroundColor: Colors.transparent),
      routes: {
        '/': (BuildContext context) {
          return ChangeNotifierProvider<HomeModel>(
            child: HomePage(),
            builder: (context) => HomeModel(),
          );
        },
        "/chat_detail": (context) {
          return ChangeNotifierProvider<ChatModel>(
            child: ChatDetailPage(
              title: "WeChat",
            ),
            builder: (context) => ChatModel(),
          );
        },
        "/subscription_box": (context) {
          return ChangeNotifierProvider<SubscriptionBoxModel>(
            child: SubscriptionBoxPage(),
            builder: (context) => SubscriptionBoxModel(),
          );
        },
        "/moments": (context) {
          return ChangeNotifierProvider<MomentsModel>(
            child: MomentsPage(),
            builder: (context) => MomentsModel(),
          );
        }
      },
    );
  }
}
