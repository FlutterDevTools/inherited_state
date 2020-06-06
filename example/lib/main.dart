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
        immutables: [
          Inject<AppConfig>(() => const AppConfig(
                appName: 'Inherited State Example',
                baseUrl: 'https://reqres.in/api',
              )),
          Inject<ApiService>(() => ApiService(IS.get())),
          Inject<CounterService>(() => CounterService(IS.get())),
        ],
        builder: (_) {
          // final appConfig = IS.get<AppConfig>();
          //IS.get<AppConfig>();
          return MaterialApp(
            title: AppConfig.get().appName,
            home: MyHomePage(title: AppConfig.get().appName),
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
    // initialCounterFuture.then((value) =>
    //     RS.get<Counter>().setState((counter) => counter.count = value));
    initialCounterFuture
        .then((value) => RS.set<Counter>((counter) => counter.count = value));
  }

  void _incrementCounter() {
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
