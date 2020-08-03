import 'package:inherited_state/inherited_state.dart';
import 'package:inherited_state_example/models/counter.dart';

class TestService {
  TestService(this._counter) {
    _counter.stateListener.addListener(_onChange);
  }

  void _onChange() {
    print(_counter.state.count);
  }

  final ReactiveController<Counter> _counter;

  void dispose() {
    _counter.stateListener.removeListener(_onChange);
  }
}
