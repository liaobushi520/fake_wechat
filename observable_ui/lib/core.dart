import 'dart:collection';

import 'package:flutter/widgets.dart';

mixin Observer<T extends StatefulWidget> on State<T> {
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
  void add(T element) {
    super.add(element);
    notifyObservers();
  }

  @override
  T removeAt(int index) {
    var r = super.removeAt(index);
    notifyObservers();
    return r;
  }

  @override
  void addAll(Iterable<T> iterable) {
    super.addAll(iterable);
    notifyObservers();
  }

  @override
  void clear() {
    super.clear();
    notifyObservers();
  }

  @override
  bool remove(Object element) {
    var r = super.remove(element);
    notifyObservers();
    return r;
  }

  @override
  void operator []=(int index, T value) {
    _value[index] = value;
  }

  @override
  set length(int newLength) {
    _value.length = newLength;
  }
}

class ObservableValue<T> with Observable<T> {
  T _value;

  T get value => _value;

  ObservableValue(T initValue) {
    this._value = initValue;
  }

  void setValue(T newValue) {
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
    with Observer {
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
      observable?.addObserver(this);
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
