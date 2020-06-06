import 'package:inherited_state/inherited_state.dart';

class AppConfig {
  const AppConfig({this.appName, this.baseUrl});
  final String appName;
  final String baseUrl;

  static AppConfig get() => IS.get<AppConfig>();
}
