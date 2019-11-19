import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'core.dart';

///EditableTextEx  support two-way binding
class EditableTextEx extends StatefulWidget {
  final EditableText child;

  final ObservableValue<String> data;

  const EditableTextEx({Key key, this.child, this.data}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EditableTextExState();
  }
}

class EditableTextExState extends StateMixinObserver<EditableTextEx> {
  EditableText wrapperEditable;

  @override
  void initState() {
    super.initState();
    var editableText = this.widget.child;
    var controller = editableText.controller;
    if (controller == null) {
      controller = TextEditingController();
    }
    controller.text = this.widget.data.value;
    wrapperEditable = EditableText(
      style: editableText.style,
      backgroundCursorColor: editableText.backgroundCursorColor,
      enableInteractiveSelection: editableText.enableInteractiveSelection,
      expands: editableText.expands,
      cursorWidth: editableText.cursorWidth,
      cursorOffset: editableText.cursorOffset,
      cursorColor: editableText.cursorColor,
      cursorOpacityAnimates: editableText.cursorOpacityAnimates,
      focusNode: editableText.focusNode,
      inputFormatters: editableText.inputFormatters,
      textInputAction: editableText.textInputAction,
      textAlign: editableText.textAlign,
      textCapitalization: editableText.textCapitalization,
      textDirection: editableText.textDirection,
      textScaleFactor: editableText.textScaleFactor,
      controller: controller,
      onChanged: (text) {
        this.widget.data.value = text;
      },
      obscureText: editableText.obscureText,
      onEditingComplete: editableText.onEditingComplete,
      onSelectionChanged: editableText.onSelectionChanged,
      onSelectionHandleTapped: editableText.onSelectionHandleTapped,
      scrollController: editableText.scrollController,
      scrollPadding: editableText.scrollPadding,
      scrollPhysics: editableText.scrollPhysics,
      showCursor: editableText.showCursor,
      showSelectionHandles: editableText.showSelectionHandles,
      strutStyle: editableText.strutStyle,
      selectionColor: editableText.selectionColor,
      selectionControls: editableText.selectionControls,
      autofocus: editableText.autofocus,
      autocorrect: editableText.autocorrect,
      paintCursorAboveText: editableText.paintCursorAboveText,
      dragStartBehavior: editableText.dragStartBehavior,
      enableSuggestions: editableText.enableSuggestions,
      rendererIgnoresPointer: editableText.rendererIgnoresPointer,
      minLines: editableText.minLines,
      maxLines: editableText.maxLines,
      forceLine: editableText.forceLine,
    );
  }

  @override
  Widget build(BuildContext context) {
    wrapperEditable.controller.text = this.widget.data.value;
    return wrapperEditable;
  }

  @override
  void setState(fn) {
    if (this.wrapperEditable.controller.text == this.widget.data.value) {
      return;
    }
    super.setState(fn);
  }

  @override
  List<Observable> collectObservables() => [this.widget.data];
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

///CheckBoxEx support two-way binding
class CheckboxEx extends StatefulWidget {
  final Checkbox child;

  final ObservableValue<bool> data;

  const CheckboxEx({Key key, this.data, this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CheckboxExState();
  }
}

class _CheckboxExState extends StateMixinObserver<CheckboxEx> {
  Checkbox wrapperCheckbox;

  @override
  void initState() {
    super.initState();
    var cb = this.widget.child;
    wrapperCheckbox = Checkbox(
      tristate: cb.tristate,
      materialTapTargetSize: cb.materialTapTargetSize,
      value: this.widget.data.value,
      activeColor: cb.activeColor,
      checkColor: cb.checkColor,
      onChanged: (v) {
        this.widget.data.value = v;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return wrapperCheckbox;
  }

  @override
  void setState(fn) {
    if (this.wrapperCheckbox.value == this.widget.data.value) {
      return;
    }
    super.setState(fn);
  }

  @override
  List<Observable> collectObservables() {
    return [this.widget.data];
  }
}

///ListViewEx

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class _ListViewBuilder {
  final WidgetBuilder builder;

  _ListViewBuilder(this.builder);
}

class ListViewEx<T> extends StatefulWidget {
  final ObservableList<T> items;

  final _ListViewBuilder listViewBuilder;

  const ListViewEx({Key key, this.items, this.listViewBuilder})
      : super(key: key);

  ListViewEx.builder({
    Key key,
    this.items,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController controller,
    bool primary,
    ScrollPhysics physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry padding,
    double itemExtent,
    @required ItemWidgetBuilder itemBuilder,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    double cacheExtent,
    int semanticChildCount,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
  })  : listViewBuilder = _ListViewBuilder((context) {
          return ListView.builder(
            itemBuilder: (context, index) {
              return itemBuilder(context, items[index]);
            },
            scrollDirection: scrollDirection,
            reverse: reverse,
            controller: controller,
            primary: primary,
            physics: physics,
            shrinkWrap: shrinkWrap,
            padding: padding,
            itemCount: items.length,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
            cacheExtent: cacheExtent,
            semanticChildCount: semanticChildCount,
            dragStartBehavior: dragStartBehavior,
          );
        }),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ListViewExState();
  }
}

class _ListViewExState extends StateMixinObserver<ListViewEx> {
  @override
  Widget build(BuildContext context) {
    return this.widget.listViewBuilder.builder(context);
  }

  @override
  List<Observable> collectObservables() => [this.widget.items];
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
