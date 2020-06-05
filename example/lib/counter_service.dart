import 'dart:math';

import 'package:inherited_state_example/api_service.dart';

class CounterService {
  CounterService(this._apiService);

  final ApiService _apiService;
  final _random = Random();

  Future<int> getInitialCounter() async {
    await _apiService.get<int>();
    return _random.nextInt(500) + 9000;
  }
}
