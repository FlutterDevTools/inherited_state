import 'package:flutter/widgets.dart';

import 'state_controller.dart';

///Inherited widget class
class InheritedInject<T> extends InheritedWidget {
  ///Inherited widget class
  const InheritedInject({Key key, Widget child, this.getSingleton})
      : super(key: key, child: child);

  ///get reactive singleton associated with this InheritedInject
  final StateController<T> Function() getSingleton;

  ///get The model
  StateController<T> get model => getSingleton();

  @override
  bool updateShouldNotify(InheritedInject<T> oldWidget) {
    return true;
  }
}
