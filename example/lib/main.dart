import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inherited_state/inherited_state.dart';
import 'package:inherited_state_example/admin_page.dart';
import 'package:inherited_state_example/services/test_service.dart';

import 'models/counter.dart';
import 'services/api_service.dart';
import 'services/app_config.dart';
import 'services/counter_service.dart';

void main() {
  ServiceLocator.config = const ServiceLocatorConfig(throwOnUnregisered: false);
  registerDependencies();
  runApp(MyApp());
}

void registerDependencies() {
  SL.register(
    () => const AppConfig(
      appName: 'Inherited State Example',
      baseUrl: 'https://reqres.in/api',
    ),
  );
  SL.register(() => ApiService(SL.get()!));
  SL.register(() => TestService(RS.getReactiveFromRoot()));
  SL.register(() => CounterService(SL.get()!));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InheritedState(
        states: [
          Inject<Counter>(() => Counter(count: 0)),
        ],
        builder: (_) {
          // final appConfig = InheritedService.get<AppConfig>();
          final appConfig = SL.get<AppConfig>()!;
          return MaterialApp(
            title: appConfig.appName,
            home: MyHomePage(title: appConfig.appName),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final counterService = SL.get<CounterService>()!;
  final testService = SL.get<TestService>()!;
  late Future<int> initialCounterFuture;

  @override
  void initState() {
    super.initState();
    initialCounterFuture = counterService.getInitialCounter();
    // Long form
    // initialCounterFuture.then((value) =>
    //     ReactiveService.getReactive<Counter>().setState((counter) => counter.count = value));
    // Short form - Mutatable update
    initialCounterFuture.then((value) =>
        RS.set<Counter>(context, (counter) => counter.count = value));
  }

  void _incrementCounter() {
    // Immutable update (creates a new instance)
    final result = RS.set<Counter>(
      context,
      (obj) => Counter(count: obj.count + 1),
    );

    // Mutable update (reuses same instance)
    // final result = context.dispatch<Counter>(
    //   (obj) => obj.count += 1,
    // );

    print('increment result: $result / #code: ${result.hashCode}');
  }

  @override
  Widget build(BuildContext context) {
    // shortcut api
    // final counter = RS.get<Counter>(context);

    // extensions api
    final counter = context.on<Counter>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push<dynamic>(
              context,
              CupertinoPageRoute<dynamic>(
                builder: (_) => AdminPage(),
              ),
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            const SizedBox(height: 20),
            _buildFutureWaiter(
                (isReady) => Text(
                      '${counter.count}',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                true),
          ],
        ),
      ),
      floatingActionButton: _buildFutureWaiter(
        (isReady) {
          return FloatingActionButton(
            backgroundColor: isReady ? null : Colors.grey,
            disabledElevation: 0,
            onPressed: isReady ? _incrementCounter : null,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildFutureWaiter(Widget Function(bool isReady) builder,
          [bool showSpinner = false]) =>
      FutureBuilder<int>(
        future: initialCounterFuture,
        builder: (_, snapshot) => showSpinner && !snapshot.hasData
            ? const CircularProgressIndicator()
            : builder(snapshot.hasData),
      );
}
