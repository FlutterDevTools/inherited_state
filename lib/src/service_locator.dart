/// Alias for [ServiceLocator]
class SL {
  /// Alias for [ServiceLocator.get]
  static T get<T>() => ServiceLocator.get();
  static void register<T>(T Function() instance) =>
      ServiceLocator.register(instance);
  static void registerWithType(Type type, dynamic Function() instance) =>
      ServiceLocator.registerWithType(type, instance);
}

/// [ServiceLocator] is used to access a service class instance of a given pre-registered type.
/// This instance is not reactive and is useful for accessing objects like services, configs, etc.
class ServiceLocator {
  static final _serviceMap = <String, ServiceInject<dynamic>>{};

  static String getName<T>() => '$T';

  /// Provides a way to access a pre-registered instance of type [T].
  static T get<T>() => _serviceMap[getName<T>()].singleton as T;

  static void register<T>(T Function() instance) =>
      _serviceMap[getName<T>()] = ServiceInject<T>(instance);
  static void registerWithType(Type type, dynamic Function() instance) =>
      _serviceMap[type.toString()] = ServiceInject<dynamic>(instance);
}

class ServiceInject<T> {
  ServiceInject(this.creationFunction);
  final T Function() creationFunction;

  T _singleton;
  T get singleton => _singleton ??= creationFunction();
}
