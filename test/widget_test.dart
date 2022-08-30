import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:registrar/registrar.dart';

const _number = 42;

/// Test app for all widget tests
///
/// [listen] true to listen to [My]
/// [registerViewModel] true to register [MyTestWidgetViewModel]
/// [viewModelName] is option name of registered [MyTestWidgetViewModel]
Widget testApp({
  required bool inherited,
  required bool listen,
}) =>
    MaterialApp(
      home: Registrar(
        builder: () => MyModel(),
        inherited: inherited,
        child: MyObserverWidget(inherited: inherited, listen: listen),
      ),
    );

class MyModel extends ChangeNotifier {
  MyModel();

  int number = _number;

  void incrementNumber() {
    number++;
    notifyListeners();
  }
}

class MyObserverWidget extends StatefulWidget {
  const MyObserverWidget({
    super.key,
    required this.inherited,
    required this.listen,
  });

  final bool inherited;
  final bool listen;

  @override
  State<MyObserverWidget> createState() => _MyObserverWidgetState();
}

class _MyObserverWidgetState extends State<MyObserverWidget> with Observer {
  MyModel getModel(BuildContext context) {
    return widget.inherited ? context.get<MyModel>() : Registrar.get<MyModel>();
  }

  MyModel listenToModel(BuildContext context) {
    return widget.inherited ? context.listenTo<MyModel>() : listenTo<MyModel>(listener: () => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final myModel = widget.listen ? listenToModel(context) : getModel(context);
    return Column(
      children: <Widget>[
        OutlinedButton(onPressed: () => myModel.incrementNumber(), child: const Text('increment number')),
        Text('${myModel.number}'),
      ],
    );
  }
}

void main() {
  setUp(() {
    /// Ensure no residuals
    expect(Registrar.isRegistered<MyModel>(), false);
  });

  tearDown(() {
    /// Ensure no residuals
    expect(Registrar.isRegistered<MyModel>(), false);
  });

  group('MyTestWidget', () {
    testWidgets('not listening to registered Registrar does not rebuild widget', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(inherited: false, listen: false));

      expect(Registrar.isRegistered<MyModel>(), true);
      expect(find.text('$_number'), findsOneWidget);

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      expect(find.text('$_number'), findsOneWidget);
    });

    testWidgets('listening to registered Registrar rebuilds widget', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(inherited: false, listen: true));

      expect(Registrar.isRegistered<MyModel>(), true);
      expect(find.text('$_number'), findsOneWidget);

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      expect(find.text('${_number + 1}'), findsOneWidget);
    });

    testWidgets('not listening to inherited Registrar does not rebuild widget', (WidgetTester tester) async {
      expect(Registrar.isRegistered<MyModel>(), false);
      await tester.pumpWidget(testApp(inherited: true, listen: false));

      expect(Registrar.isRegistered<MyModel>(), false);
      expect(find.text('$_number'), findsOneWidget);

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      expect(find.text('$_number'), findsOneWidget);
    });

    testWidgets('listening to inherited Registrar rebuilds widget', (WidgetTester tester) async {
      expect(Registrar.isRegistered<MyModel>(), false);
      await tester.pumpWidget(testApp(inherited: true, listen: true));

      expect(find.text('$_number'), findsOneWidget);

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      expect(find.text('${_number + 1}'), findsOneWidget);
    });
  });
}
