import 'dart:collection';

import 'package:flutter/widgets.dart';

class ListenableList<T> extends ChangeNotifier with ListMixin<T> {
  final List<T> _value = [];

  ListenableList({List<T> initValue}) {
    if (initValue != null) {
      _value.addAll(initValue);
    }
  }

  @override
  int get length => _value.length;

  @override
  T operator [](int index) {
    return _value[index];
  }

  @override
  void operator []=(int index, T value) {
    _value[index] = value;
    notifyListeners();
  }

  @override
  set length(int newLength) {
    _value.length = newLength;
    notifyListeners();
  }
}

mixin ListenerMixin<T extends StatefulWidget> on State<T> {
  void onChanged() {
    setState(() {});
  }
}

abstract class StateMixinListener<T extends StatefulWidget> extends State<T>
    with ListenerMixin {
  List<Listenable> _listenables = [];

  List<Listenable> collectListenable();

  @mustCallSuper
  @override
  void initState() {
    super.initState();
    _addListenables(collectListenable());
  }

  void _addListenables(List<Listenable> listenables) {
    listenables?.forEach((listenable) {
      listenable.addListener(this.onChanged);
    });
    _listenables.addAll(listenables);
  }

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();
    _listenables.forEach((listenable) {
      listenable.removeListener(this.onChanged);
    });
    _listenables.clear();
  }
}

class ListenableBridge extends StatefulWidget {
  final Widget Function(BuildContext context) childBuilder;

  final List<Listenable> data;

  const ListenableBridge({Key key, @required this.data, this.childBuilder})
      : assert(
          childBuilder != null,
          ' childBuilder are null.',
        ),
        super(key: key);

  @override
  State<ListenableBridge> createState() {
    return _ListenableBridgeState();
  }
}

class _ListenableBridgeState extends StateMixinListener<ListenableBridge> {
  @override
  Widget build(BuildContext context) {
    return widget.childBuilder(context);
  }

  @override
  List<Listenable> collectListenable() {
    final listenables = <Listenable>[];
    listenables.addAll(widget.data);
    return listenables;
  }
}
