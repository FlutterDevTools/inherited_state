/// Alias for [ServiceLocator]
class SL {
  /// Alias for [ServiceLocator.get]
  static T? get<T>() => ServiceLocator.get();
  static List<Object> getAll() => ServiceLocator.getAll();
  static void register<T>(T Function() instance) =>
      ServiceLocator.register(instance);
  static void registerWithType(Type type, dynamic Function() instance) =>
      ServiceLocator.registerWithType(type, instance);
}

class ServiceLocatorConfig {
  const ServiceLocatorConfig(
      {this.throwOnUnregisered = false, this.defaultLazy = true});
  final bool defaultLazy;
  final bool throwOnUnregisered;
}

// ignore: avoid_classes_with_only_static_members
/// [ServiceLocator] is used to access a service class instance of a given pre-registered type.
/// This instance is not reactive and is useful for accessing objects like services, configs, etc.
class ServiceLocator {
  static var config = const ServiceLocatorConfig();
  static final _serviceMap = <String, ServiceInject<dynamic>>{};

  static String getName<T>() => '$T';

  /// Provides a way to access a pre-registered instance of type [T].
  static T? get<T>() {
    final instance = _serviceMap[getName<T>()]?.singleton as T?;
    if (instance == null) {
      final message = '${T.toString()} is not registered.';
      if (config.throwOnUnregisered)
        throw Exception(message);
      else
        print(message);
    }
    return instance;
  }

  static List<Object> getAll() =>
      _serviceMap.values.map((e) => e.singleton as Object).toList();

  static void register<T>(T Function() instance, {bool? lazy}) =>
      _serviceMap[getName<T>()] =
          ServiceInject<T>(instance, lazy: lazy ?? config.defaultLazy);
  static void registerWithType(Type type, dynamic Function() instance,
          {bool? lazy}) =>
      _serviceMap[type.toString()] =
          ServiceInject<dynamic>(instance, lazy: lazy ?? config.defaultLazy);
}

class ServiceInject<T> {
  ServiceInject(this.creationFunction, {this.lazy = true}) {
    if (!lazy) _singleton = creationFunction();
  }
  final bool lazy;
  final T Function() creationFunction;

  T? _singleton;
  T get singleton => _singleton ??= creationFunction();
}
