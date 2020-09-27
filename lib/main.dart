import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/memonts_model.dart';

import 'package:flutter_app/page/wechat/moments_page.dart';
import 'package:flutter_app/page/wechat/subscription_message_page.dart';
import 'package:flutter_app/subscription_box_model.dart';
import 'package:observable_ui/provider.dart';

import 'app_model.dart';
import 'home_model.dart';
import 'home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelProvider(
      child: MaterialApp(
        title: 'WeChat',
        theme: ThemeData(
            primarySwatch: Colors.green,
            backgroundColor: Colors.transparent),
        home:ViewModelProvider(
          viewModel: HomeModel(),
          child: HomePage(),
        ) ,
        routes: {
          "/subscription_box": (context) {
            return ViewModelProvider<SubscriptionBoxModel>(
              child: SubscriptionBoxPage(),
              viewModel: SubscriptionBoxModel(),
            );
          },
        },
      ),
      viewModel: AppModel(),
    );
  }
}
