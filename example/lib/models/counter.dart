import 'package:inherited_state/inherited_state.dart';

class Counter {
  Counter([this.count]);
  int count = 0;

  @override
  String toString() {
    return 'Counter($count)';
  }

  static Counter state([dynamic Function(Counter) call]) {
    final value = RS.get<Counter>();
    if (call != null) {
      value.setState(call);
    }
    return value.state;
  }
}
