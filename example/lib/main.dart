import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:view/registrar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Registrar<ColorNotifier>(
        builder: () => ColorNotifier(),
        child: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    Registrar.get<ColorNotifier>().addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    Registrar.get<ColorNotifier>().removeListener(() => setState(() {}));
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiRegistrar(
      delegates: [
        RegistrarDelegate<FortyTwoService>(builder: () => FortyTwoService()),
        RegistrarDelegate<RandomService>(builder: () => RandomService()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_counter',
                style: TextStyle(fontSize: 64, color: Registrar.get<ColorNotifier>().color),
              ),
              OutlinedButton(
                onPressed: () => setState(() {
                  _counter = Registrar.get<RandomService>().number;
                }),
                child: const Text('Set Random'),
              ),
              OutlinedButton(
                onPressed: () => setState(() {
                  _counter = Registrar.get<FortyTwoService>().number;
                }),
                child: const Text('Set 42'),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class ColorNotifier extends ChangeNotifier {
  ColorNotifier() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      color = <Color>[Colors.orange, Colors.purple, Colors.cyan][++_counter % 3];
      notifyListeners();
    });
  }

  late Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  int _counter = 0;
  Color color = Colors.black;
}

class FortyTwoService {
  final int number = 42;
}

class RandomService {
  int get number => Random().nextInt(100);
}
