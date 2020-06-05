import 'package:inherited_state_example/app_config.dart';

class ApiService {
  const ApiService(this._appConfig);

  final AppConfig _appConfig;

  Future<T> get<T>() async {
    final baseUrl = _appConfig.baseUrl;
    // Make API request
    await Future<dynamic>.delayed(const Duration(seconds: 1));
    return null;
  }
}
