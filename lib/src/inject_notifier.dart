import 'package:flutter/foundation.dart';

class InjectNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  InjectNotifier(this._value);
  @override
  T get value => _value;
  T _value;
  set value(T newValue) {
    _value = newValue;
    notifyListeners();
  }
}
