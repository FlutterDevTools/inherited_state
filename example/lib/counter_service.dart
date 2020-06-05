import 'dart:math';

class CounterService {
  final _random = Random();
  Future<int> getInitialCounter() async {
    await Future<dynamic>.delayed(const Duration(seconds: 2));
    return _random.nextInt(500) + 9000;
  }
}
