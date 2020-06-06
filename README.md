# inherited_state

Simple scoped reactive state management (using [InheritedWidget]) and DI. Supports both immutable and mutable updates.

# Quick Start
*pubspec.yaml*
```yaml
inherited_state: ^0.0.1
```

## Setup
`InheritedState` widget needs to be part of the tree as an ancestor to be able to use it from the descendent widgets similar to the usage of `InheritedWidget`. You can register the reactive states and services using the `reactives` and `services` arguments, respectively.

```dart
InheritedState(
    reactives: [
        Inject<Counter>(() => Counter(0)),
    ],
    services: [
        Inject<AppConfig>(() => const AppConfig(
            appName: 'Inherited State Example',
            baseUrl: 'https://reqres.in/api',
            )),
        Inject<ApiService>(() => ApiService(IS.get())),
        Inject<CounterService>(() => CounterService(IS.get())),
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
  final res = RS.set<Counter>((counter) => Counter(counter.count + 1));
}

// Pass context to the `RS.get` method to subscribe to changes (widget automatically rebuilds when changes occur).
@override
Widget build(BuildContext context) {
    final counter = RS.get<Counter>(context);
    ...
}
```

### Inherited Service (DI) - Services, Configs, etc.
```dart
// IS is an alias for InheritedService.
final counterService = IS.get<CounterService>();
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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InheritedState(
        reactives: [
          Inject<Counter>(() => Counter(0)),
        ],
        services: [
          Inject<AppConfig>(() => const AppConfig(
                appName: 'Inherited State Example',
                baseUrl: 'https://reqres.in/api',
              )),
          Inject<ApiService>(() => ApiService(IS.get())),
          Inject<CounterService>(() => CounterService(IS.get())),
        ],
        builder: (_) {
          // final appConfig = InheritedService.get<AppConfig>();
          final appConfig = IS.get<AppConfig>();
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
  final counterService = IS.get<CounterService>();
  Future<int> initialCounterFuture;

  @override
  void initState() {
    super.initState();
    initialCounterFuture = counterService.getInitialCounter();
    // Long form
    // initialCounterFuture.then((value) =>
    //     ReactiveService.getReactive<Counter>().setState((counter) => counter.count = value));
    // Short form - Mutatable update
    initialCounterFuture
        .then((value) => RS.set<Counter>((counter) => counter.count = value));
  }

  void _incrementCounter() {
    // Immutable update
    final res = RS.set<Counter>((counter) => Counter(counter.count + 1));
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
            _buildFutureCounter(
              (snapshot) => snapshot.hasData
                  ? Text(
                      '${counter.count}',
                      style: Theme.of(context).textTheme.headline4,
                    )
                  : const CircularProgressIndicator(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFutureCounter(
        (snapshot) {
          print('floats $counter');
          return FloatingActionButton(
            backgroundColor: snapshot.hasData ? null : Colors.grey,
            disabledElevation: 0,
            onPressed: snapshot.hasData ? _incrementCounter : null,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildFutureCounter(Widget Function(AsyncSnapshot) builder) =>
      FutureBuilder<int>(
        future: initialCounterFuture,
        builder: (_, snapshot) => builder(snapshot),
      );
}
```
</details>

[View file](example/lib/main.dart)

# Inherited State Widget


# Reactive State

# Immutable State
