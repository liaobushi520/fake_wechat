import 'package:flutter/widgets.dart';

Type _typeOf<T>() => T;

class ViewModelNotFoundError extends Error {
  /// The type of the value being retrieved
  final Type valueType;

  /// The type of the Widget requesting the value
  final Type widgetType;

  /// Create a ProviderNotFound error with the type represented as a String.
  ViewModelNotFoundError(
    this.valueType,
    this.widgetType,
  );

  @override
  String toString() {
    return '''
       Error: Could not find the correct ViewModelProvider<$valueType> above this $widgetType Widget
       ''';
  }
}

class ViewModelProvider<T> extends InheritedWidget {
  final T viewModel;

  const ViewModelProvider({@required this.viewModel, Key key, Widget child})
      : assert(viewModel != null, "ViewModel can not be null"),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(ViewModelProvider oldWidget) {
    return this.viewModel != oldWidget.viewModel;
  }

  static T of<T>(BuildContext context, {bool listen = true}) {
    final type = _typeOf<ViewModelProvider<T>>();
    final provider = listen
        ? context.inheritFromWidgetOfExactType(type) as ViewModelProvider<T>
        : context.ancestorInheritedElementForWidgetOfExactType(type)?.widget
            as ViewModelProvider<T>;

    if (provider == null) {
      throw ViewModelNotFoundError(T, context.widget.runtimeType);
    }
    return provider.viewModel;
  }
}
