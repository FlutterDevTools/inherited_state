# inherited_state

Simple scoped reactive state management (using [InheritedWidget]) and DI. Supports both immutable and mutable updates.

# Quick Start
*pubspec.yaml*
```yaml
inherited_state: ^2.1.0
```

## Setup State Management
`InheritedState` widget needs to be part of the tree as an ancestor to be able to use it from the descendent widgets similar to the usage of `InheritedWidget`. You can register the reactive states using the `states` argument.

```dart
InheritedState(
    states: [
        Inject<Counter>(() => Counter(0)),
    ],
    builder: (_) =>
    ...
)
```

### Reactive State - UI Change Notifications
```dart
// Plain dart class
class Counter {
    Counter(this.count);
    int count = 0;
}

// RS is an alias for ReactiveState.
void _incrementCounter() {
  // Immutable update
  final res = RS.set<Counter>(context, (counter) => Counter(counter.count + 1));
}

// Pass context to the `RS.get` method to subscribe to changes (widget automatically rebuilds when changes occur).
@override
Widget build(BuildContext context) {
    final counter = RS.get<Counter>(context);
    ...
}
```

## Setup DI
```dart
void main() {
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
  SL.register(() => ApiService(SL.get()));
  SL.register(() => CounterService(SL.get()));
}
```

### Service Locator (DI) - Services, Configs, etc.
```dart
// SL is an alias for ServiceLocator.
final counterService = SL.get<CounterService>();
```

## Full Example with Reactive states and Services

<details>
  <summary>main.yaml</summary>

```dart
import 'package:flutter/material.dart';
import 'package:inherited_state/inherited_state.dart';

import 'models/counter.dart';
import 'services/api_service.dart';
import 'services/app_config.dart';
import 'services/counter_service.dart';

void main() {
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
  SL.register(() => ApiService(SL.get()));
  SL.register(() => CounterService(SL.get()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InheritedState(
        states: [
          Inject<Counter>(() => Counter(0)),
        ],
        builder: (_) {
          // final appConfig = InheritedService.get<AppConfig>();
          final appConfig = SL.get<AppConfig>();
          return MaterialApp(
            title: appConfig.appName,
            home: MyHomePage(title: appConfig.appName),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final counterService = SL.get<CounterService>();
  Future<int> initialCounterFuture;

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
    // Immutable update
    final res =
        RS.set<Counter>(context, (counter) => Counter(counter.count + 1));
    print('increment result: $res');
  }

  @override
  Widget build(BuildContext context) {
    final counter = RS.get<Counter>(context);
    print('rebuild: $counter');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
          print('floats $counter');
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


```
</details>

[View file](example/lib/main.dart)

# Inherited State Widget
This widget is used to setup the reactive state instances available to the descendants. It can be used multiple times at different tree nodes. 

# Reactive State
Reactive state allows for subscriptions and updates to the underlying model in an immutable and mutable fashion depending on developer preference.

# Services
`ServiceLocator` allows for a simple way of registering global dependencies that can be used anywhere within the app without relying on flutter context or any sort of UI related mechanism. Services can be accessed and referenced and the reference is always a singleton.
