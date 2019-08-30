import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'core.dart';

///ObservableBridge
typedef WidgetBuilder = Widget Function(BuildContext context);

class ObservableBridge extends StatefulWidget {
  final WidgetBuilder childBuilder;

  final List<Observable> data;

  const ObservableBridge({Key key, this.data, this.childBuilder}) : super(key: key);

  @override
  State<ObservableBridge> createState() {
    return ObservableBridgeState();
  }
}

class ObservableBridgeState extends StateMixinObserver<ObservableBridge> {
  @override
  Widget build(BuildContext context) {
    return widget.childBuilder(context);
  }

  @override
  List<Observable> collectObservables() {
    final observables = <Observable>[];
    observables.addAll(widget.data);
    return observables;
  }
}

///TextEx

class TextEx extends StatefulWidget {
  const TextEx({Key key, this.data}) : super(key: key);

  final ObservableValue<String> data;

  @override
  State<TextEx> createState() {
    return TextExState();
  }
}

class TextExState extends StateMixinObserver<TextEx> {
  @override
  Widget build(BuildContext context) {
    return Text(this.widget.data.value);
  }

  @override
  List<Observable> collectObservables() => [this.widget.data];
}

///VisibilityEx
class VisibilityEx extends StatefulWidget {
  const VisibilityEx({Key key, @required this.child, this.visible})
      : super(key: key);

  final ObservableValue<bool> visible;

  final Widget child;

  @override
  State<StatefulWidget> createState() {
    return VisibilityExState();
  }
}

class VisibilityExState extends StateMixinObserver<VisibilityEx> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
        child: this.widget.child, visible: this.widget.visible.value);
  }

  @override
  List<Observable> collectObservables() => [this.widget.visible];
}

///ImageEx
class ImageEx extends StatefulWidget {
  const ImageEx({Key key, this.src, this.width, this.height}) : super(key: key);

  ///file path , network url ,asset name
  final ObservableValue<String> src;

  final double width;

  final double height;

  @override
  State<StatefulWidget> createState() {
    return ImageExState();
  }
}

class ImageExState extends StateMixinObserver<ImageEx> {
  @override
  List<Observable> collectObservables() => [this.widget.src];

  @override
  Widget build(BuildContext context) {
    var img = this.widget.src.value;
    if (img.startsWith("http")) {
      return Image.network(
        img,
        width: this.widget.width,
        height: this.widget.height,
      );
    }
    if (img.startsWith("/")) {
      return Image.file(
        File(img),
        width: this.widget.width,
        height: this.widget.height,
      );
    }
    return Image.asset(
      img,
      width: this.widget.width,
      height: this.widget.height,
    );
  }
}

///CheckBoxEx
class CheckboxEx extends StatefulWidget {
  final ObservableValue<bool> value;

  final ValueChanged<bool> onChanged;

  final Color activeColor;

  const CheckboxEx({Key key, this.value, this.onChanged, this.activeColor})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CheckboxExState();
  }
}

class CheckboxExState extends StateMixinObserver<CheckboxEx> {
  @override
  List<Observable> collectObservables() => [this.widget.value];

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: this.widget.value.value,
      onChanged: this.widget.onChanged,
      activeColor: this.widget.activeColor,
    );
  }
}

///FlatButtonEx
class FlatButtonEx extends StatefulWidget {
  final Widget child;

  final VoidCallback onPressed;

  final ObservableValue<bool> enable;

  const FlatButtonEx({Key key, this.child, this.onPressed, this.enable})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FlatButtonExState();
  }
}

class FlatButtonExState extends StateMixinObserver<FlatButtonEx> {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: this.widget.child,
      onPressed: this.widget.enable.value ? this.widget.onPressed : null,
    );
  }

  @override
  List<Observable> collectObservables() => [this.widget.enable];
}

///OpacityEx
class OpacityEx extends StatefulWidget {
  final ObservableValue<double> opacity;

  final Widget child;

  final bool alwaysIncludeSemantics;

  const OpacityEx(
      {Key key,
      @required this.opacity,
      this.alwaysIncludeSemantics,
      this.child})
      : super(key: key);

  @override
  State<OpacityEx> createState() {
    return OpacityExState();
  }
}

class OpacityExState extends StateMixinObserver<OpacityEx> {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: this.widget.opacity.value,
      child: this.widget.child,
      alwaysIncludeSemantics: this.widget.alwaysIncludeSemantics,
    );
  }

  @override
  List<Observable> collectObservables() => [this.widget.opacity];
}

///LinearProgressIndicator
class LinearProgressIndicatorEx extends StatefulWidget {
  final ObservableValue<double> value;

  final Color backgroundColor;

  const LinearProgressIndicatorEx({Key key, this.value, this.backgroundColor})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LinearProgressIndicatorExState();
  }
}

class LinearProgressIndicatorExState
    extends StateMixinObserver<LinearProgressIndicatorEx> {
  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: this.widget.value.value,
      backgroundColor: this.widget.backgroundColor,
    );
  }

  @override
  List<Observable> collectObservables() => [this.widget.value];
}

///FractionallySizedBoxEx
class FractionallySizedBoxEx extends StatefulWidget {
  final ObservableValue<double> widthFactor;

  final ObservableValue<double> heightFactor;

  final AlignmentGeometry alignment;

  final Widget child;

  const FractionallySizedBoxEx(
      {Key key,
      this.widthFactor,
      this.heightFactor,
      this.alignment,
      this.child})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FractionallySizedBoxExState();
  }
}

class FractionallySizedBoxExState
    extends StateMixinObserver<FractionallySizedBoxEx> {
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: this.widget.widthFactor.value,
      heightFactor: this.widget.heightFactor.value,
      child: this.widget.child,
      alignment: this.widget.alignment,
    );
  }

  @override
  List<Observable> collectObservables() =>
      [this.widget.widthFactor, this.widget.heightFactor];
}

///ContainerEx

class ContainerEx extends StatefulWidget {
  final Widget child;

  final ObservableValue<EdgeInsetsGeometry> padding;

  final ObservableValue<EdgeInsetsGeometry> margin;

  const ContainerEx({Key key, this.padding, this.margin, this.child})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ContainerExState();
  }
}

class ContainerExState extends StateMixinObserver<ContainerEx> {
  @override
  List<Observable> collectObservables() =>
      [this.widget.padding, this.widget.margin];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: this.widget.child,
      padding: this.widget.padding.value,
      margin: this.widget.margin.value,
    );
  }
}

///ListViewEx
typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class ListViewEx<T> extends StatefulWidget {
  const ListViewEx({this.items, @required this.itemBuilder});

  final ObservableList<T> items;

  final ItemWidgetBuilder<T> itemBuilder;

  @override
  State<StatefulWidget> createState() {
    return ListViewExState();
  }
}

class ListViewExState extends StateMixinObserver<ListViewEx> {
  @override
  List<Observable> collectObservables() => [this.widget.items];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return this.widget.itemBuilder(context, this.widget.items[index]);
      },
      itemCount: this.widget.items.length,
    );
  }
}

///ExchangeEx  child1 visible when status is true
class ExchangeEx extends StatefulWidget {
  final Widget child1;

  final Widget child2;

  final ObservableValue<bool> status;

  const ExchangeEx(
      {Key key,
      @required this.child1,
      @required this.child2,
      @required this.status})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ExchangeExState();
  }
}

class ExchangeExState extends StateMixinObserver<ExchangeEx> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Visibility(
          visible: this.widget.status.value,
          child: this.widget.child1,
        ),
        Visibility(
          visible: !this.widget.status.value,
          child: this.widget.child2,
        )
      ],
    );
  }

  @override
  List<Observable> collectObservables() => [this.widget.status];
}
