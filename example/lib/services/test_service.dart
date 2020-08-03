import 'package:inherited_state/inherited_state.dart';
import 'package:inherited_state_example/models/counter.dart';

class TestService {
  TestService() {
    _counter.stateListener.addListener(_onChange);
  }

  void _onChange() {
    print(_counter.state.count);
  }

  final _counter = RS.getReactiveFromRoot<Counter>();

  void dispose() {
    _counter.stateListener.removeListener(_onChange);
  }
}
