import 'package:flutter/material.dart';
import 'package:observable_ui/core.dart';

class HomeModel extends ChangeNotifier {
  ObservableValue<int> currentIndex = ObservableValue(0);
}
