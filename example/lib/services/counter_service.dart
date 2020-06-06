import 'dart:math';

import 'api_service.dart';

class CounterService {
  CounterService(this._apiService);

  final ApiService _apiService;
  final _random = Random();

  Future<int> getInitialCounter() async {
    final userId = _random.nextInt(10);
    final data = await _apiService.get<Map<String, dynamic>>('users/$userId');
    return (data['data']['avatar'] as String).length;
  }
}
