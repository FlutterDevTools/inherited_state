import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:inherited_state/inherited_state.dart';

import 'models/counter.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counter = context.on<Counter>();
    final canReset = counter.count != 0;
    final resetFn =
        canReset ? () => context.set<Counter>((_) => Counter(0)) : null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text('Counter'),
            trailing: Text(counter.count.toString()),
          ),
          const Divider(thickness: 1),
          ListTile(
            enabled: canReset,
            onTap: resetFn,
            title: const Text('Reset'),
            trailing: IconButton(
              icon: const Icon(Icons.restore),
              onPressed: resetFn,
            ),
          ),
        ],
      ),
    );
  }
}
