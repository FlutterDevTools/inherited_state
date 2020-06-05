# inherited_state

Simple state management (using InheritedWidget) and DI.

# Quick Start
*pubspec.yaml*
```yaml
inherited_state: ^0.0.1
```

## Setup
`InheritedContainer` widget needs to be part of the tree as an ancestor to be able to use it from the descendent widgets similar to the usage of `InheritedWidget`. You can register the stateful and plain classes using the `inject` and `dependencies` arguments, respectively.

```dart
InheritedContainer(
    states: [
        Inject<Counter>(() => Counter(0)),
    ],
    dependencies: [
        Inject<AppConfig>(
            () => const AppConfig(appName: 'Inherited State Example')),
        Inject<CounterService>(() => CounterService()),
    ],
    builder: (_) =>
    ...
)
```

## State
```dart
// Plain dart class
class Counter {
    Counter(this.count);
    int count = 0;
}

// SC is an alias for StateContainer.
void _incrementCounter() {
    SC.get<Counter>().setState((counter) => counter.count++);
}

// Pass context to the `SC.get` method to subscribe to changes.
@override
Widget build(BuildContext context) {
    final counter = SC.get<Counter>(context: context).state;
    ...
}
```

## DI
```dart
// DC is an alias for DependencyContainer.
final counterService = DC.get<CounterService>();
```

## Full Example with Stateful and Plain

*main.yaml*
```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InheritedContainer(
        states: [
          Inject<Counter>(() => Counter(0)),
        ],
        dependencies: [
          Inject<AppConfig>(
              () => const AppConfig(appName: 'Inherited State Example')),
          Inject<CounterService>(() => CounterService()),
        ],
        builder: (_) {
          final appConfig = DC.get<AppConfig>();
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
  final counterService = DC.get<CounterService>();
  Future<int> initialCounterFuture;

  @override
  void initState() {
    super.initState();
    initialCounterFuture = counterService.getInitialCounter();
    initialCounterFuture.then((value) =>
        SC.get<Counter>().setState((counter) => counter.count = value));
  }

  void _incrementCounter() {
    SC.get<Counter>().setState((counter) => counter.count++);
  }

  @override
  Widget build(BuildContext context) {
    final counter = SC.get<Counter>(context: context).state;
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


# State Container

# Dependency Container

# Inherited Container
