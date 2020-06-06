# inherited_state

Simple state management (using InheritedWidget) and DI.

# Quick Start
*pubspec.yaml*
```yaml
inherited_state: ^0.0.1
```

## Setup
`InheritedState` widget needs to be part of the tree as an ancestor to be able to use it from the descendent widgets similar to the usage of `InheritedWidget`. You can register the stateful and immutable states using the `reactives` and `immutables` arguments, respectively.

```dart
InheritedState(
    reactives: [
        Inject<Counter>(() => Counter(0)),
    ],
    immutables: [
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

### State
```dart
// Plain dart class
class Counter {
    Counter(this.count);
    int count = 0;
}

// RS is an alias for ReactiveState.
void _incrementCounter() {
    RS.get<Counter>().setState((counter) => counter.count++);
}

// Pass context to the `RS.get` method to subscribe to changes.
@override
Widget build(BuildContext context) {
    final counter = RS.get<Counter>(context: context).state;
    ...
}
```

### DI
```dart
// IS is an alias for ImmutableState.
final counterService = IS.get<CounterService>();
```

## Full Example with Stateful and Plain

<details>
  <summary>*main.yaml*</summary>

```dart
import 'package:flutter/material.dart';
import 'package:inherited_state/inherited_state.dart';
import 'package:inherited_state_example/api_service.dart';
import 'package:inherited_state_example/app_config.dart';

import 'package:inherited_state_example/counter.dart';
import 'package:inherited_state_example/counter_service.dart';

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
        immutables: [
          Inject<AppConfig>(() => const AppConfig(
                appName: 'Inherited State Example',
                baseUrl: 'https://reqres.in/api',
              )),
          Inject<ApiService>(() => ApiService(IS.get())),
          Inject<CounterService>(() => CounterService(IS.get())),
        ],
        builder: (_) {
          final appConfig = IS.get<AppConfig>();
          return MaterialApp(
            title: appConfig.appName,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
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
    initialCounterFuture.then((value) =>
        RS.get<Counter>().setState((counter) => counter.count = value));
  }

  void _incrementCounter() {
    RS.get<Counter>().setState((counter) => counter.count++);
  }

  @override
  Widget build(BuildContext context) {
    final counter = RS.get<Counter>(context: context).state;
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
            FutureBuilder<int>(
              future: initialCounterFuture,
              builder: (_, snapshot) => snapshot.hasData
                  ? Text(
                      '${counter.count}',
                      style: Theme.of(context).textTheme.headline4,
                    )
                  : const CircularProgressIndicator(),
            ),
          ],
        ),
      ),
      floatingActionButton: FutureBuilder<int>(
        future: initialCounterFuture,
        builder: (_, snapshot) => FloatingActionButton(
          backgroundColor: snapshot.hasData ? null : Colors.grey,
          disabledElevation: 0,
          onPressed: snapshot.hasData ? _incrementCounter : null,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
```
</details>

[View file](blob/master/example/lib/main.dart)

# Inherited State Widget


# Reactive State

# Immutable State
