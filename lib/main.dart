import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/SubscriptionBoxModel.dart';
import 'package:flutter_app/chat_detail_page.dart';
import 'package:flutter_app/memonts_model.dart';
import 'package:flutter_app/moments_page.dart';
import 'package:flutter_app/subscription_message_page.dart';
import 'package:observable_ui/provider.dart';

import 'HomeModel.dart';
import 'app_model.dart';
import 'chat_model.dart';
import 'home_page.dart';
import 'music_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ViewModelProvider(
      child: MaterialApp(
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
            return ViewModelProvider(
              viewModel: HomeModel(),
              child: HomePage(),
            );
          },
          "/chat_detail": (context) {
            return ViewModelProvider(
              viewModel: ChatModel(),
              child: ChatDetailPage(
                title: "WeChat",
              ),
            );
          },
          "/subscription_box": (context) {
            return ViewModelProvider<SubscriptionBoxModel>(
              child: SubscriptionBoxPage(),
              viewModel: SubscriptionBoxModel(),
            );
          },
          "/moments": (context) {
            return ViewModelProvider(
              viewModel: MomentsModel(),
              child: MomentsPage(),
            );
          },
          "/music_player": (context) {
            return ViewModelProvider(
              viewModel: MusicPlayerModel(),
              child: MusicPlayerPage(),
            );
          },
        },
      ),
      viewModel: AppModel(),
    );
  }
}
