import 'dart:collection';

import 'package:flutter/widgets.dart';

abstract class Observer {
  void onChanged();
}

mixin ObserverMixin<T extends StatefulWidget> on State<T> implements Observer {
  @override
  void onChanged() {
    setState(() {});
  }
}

class ObservableList<T> with ListMixin<T>, Observable {
  final List<T> _value = [];

  @override
  get length => _value.length;

  @override
  T operator [](int index) {
    return _value[index];
  }

  @override
  void operator []=(int index, T value) {
    _value[index] = value;
    notifyObservers();
  }

  @override
  set length(int newLength) {
    _value.length = newLength;
    notifyObservers();
  }
}

class ObservableValue<T> with Observable<T> {
  ObservableValue(T initValue) {
    this._value = initValue;
  }

  T _oldValue;

  T get oldValue => _oldValue;

  T _value;

  T get value => _value;

  set value(newValue) {
    _oldValue = _value;
    _value = newValue;
    notifyObservers();
  }
}

mixin Observable<T> {
  List<Observer> _observers;

  void notifyObservers() {
    _observers?.forEach((observer) {
      observer.onChanged();
    });
  }

  void removeObservers() {
    _observers?.clear();
  }

  void removeObserver(Observer observer) {
    _observers?.remove(observer);
  }

  void addObserver(Observer observer) {
    if (_observers == null) {
      _observers = [];
    }
    this._observers.add(observer);
  }
}

abstract class StateMixinObserver<T extends StatefulWidget> extends State<T>
    with ObserverMixin {
  List<Observable> _observables = [];

  List<Observable> collectObservables();

  @mustCallSuper
  @override
  void initState() {
    super.initState();
    addObservables(collectObservables());
  }

  void addObservables(List<Observable> observables) {
    observables?.forEach((observable) {
      observable.addObserver(this);
    });
    _observables.addAll(observables);
  }

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();
    _observables.forEach((observable) {
      observable.removeObserver(this);
    });
    _observables.clear();
  }
}
