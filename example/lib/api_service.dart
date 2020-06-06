import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:inherited_state_example/app_config.dart';

class ApiService {
  const ApiService(this._appConfig);

  final AppConfig _appConfig;

  String get baseUrl => _appConfig.baseUrl;

  String getUrl(String relativeUrl) {
    return '$baseUrl/$relativeUrl';
  }

  Future<T> get<T>(String relativeUrl) async {
    final response = await http.get(getUrl(relativeUrl));
    return json.decode(response.body) as T;
  }
}
