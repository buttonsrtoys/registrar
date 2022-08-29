import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:registrar/registrar.dart';

const _number = 42;
const _floatDefault = 3.14159;
const _floatUpdated = 42.42;
const _stringDefault = 'Default';
const _stringUpdated = 'Updated';
const _registeredStringDefault = 'Registered Default';
const _registeredStringUpdated = 'Registered Updated';
const _namedStringDefault = 'Named Default';
const _namedStringUpdated = 'Named Updated';

/// Test app for all widget tests
///
/// [listenToRegistrar] true to listen to [My]
/// [registerViewModel] true to register [MyTestWidgetViewModel]
/// [viewModelName] is option name of registered [MyTestWidgetViewModel]
Widget testApp({
  required bool scoped,
  required bool listenToRegistrar,
}) =>
    MaterialApp(
      home: Registrar(
        builder: () => MyModel(),
        inherited: scoped,
        child: MyObserverWidget(scoped: scoped, listenToRegistrar: listenToRegistrar),
      ),
    );

class MyModel extends ChangeNotifier {
  MyModel();

  int number = _number;

  final myFloatProperty = ValueNotifier<double>(_floatDefault);

  void incrementNumber() {
    number++;
    notifyListeners();
  }
}

class MyObserverWidget extends StatelessWidget {
  const MyObserverWidget({
    super.key,
    required this.scoped,
    required this.listenToRegistrar,
  });

  final bool scoped;
  final bool listenToRegistrar;

  MyModel getModel(BuildContext context) {
    return scoped ? context.get<MyModel>() : Registrar.get<MyModel>();
  }

  MyModel listenToModel(BuildContext context) {
    return listenToRegistrar ? context.listenTo<MyModel>() : Registrar.get<MyModel>();
  }

  @override
  Widget build(BuildContext context) {
    final myModel = listenToRegistrar ? listenToModel(context) : getModel(context);
    // final float = listenTo<Property<double>>(notifier: get<MyModel>().myFloatProperty).value;
    return Column(
      children: <Widget>[
        OutlinedButton(onPressed: () => myModel.incrementNumber(), child: const Text('increment number')),
        Text('${myModel.number}'),
      ],
    );
  }
}

// Rich, need more widget tests to exercise inherited param
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
    testWidgets('not listening to unscoped Registrar does not rebuild widget', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(scoped: false, listenToRegistrar: false));

      expect(Registrar.isRegistered<MyModel>(), true);
      expect(find.text('$_number'), findsOneWidget);

      Registrar.get<MyModel>().incrementNumber();
      await tester.pump();

      // expect does not increment b/c not listening
      expect(find.text('$_number'), findsOneWidget);
    });

    testWidgets('scoped Registrar is not registered', (WidgetTester tester) async {
      expect(Registrar.isRegistered<MyModel>(), false);
      await tester.pumpWidget(testApp(scoped: true, listenToRegistrar: false));

      expect(Registrar.isRegistered<MyModel>(), false);
      expect(find.text('$_number'), findsOneWidget);

      await tester.pump();

      // expect does not increment b/c not listening
      expect(find.text('$_number'), findsOneWidget);
    });

    testWidgets('listening scoped Registrar updates value', (WidgetTester tester) async {
      expect(Registrar.isRegistered<MyModel>(), false);
      await tester.pumpWidget(testApp(scoped: true, listenToRegistrar: true));

      expect(find.text('$_number'), findsOneWidget);

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      // expect does not increment b/c not listening
      expect(find.text('${_number+1}'), findsOneWidget);
    });

    testWidgets(
      'listening to Registrar and registered ViewModel  but Model shows correct values',
      (WidgetTester tester) async {
        await tester.pumpWidget(testApp(scoped: false, listenToRegistrar: true));

        // expect default values
        expect(find.text('$_number'), findsOneWidget);
        expect(find.text(_stringDefault), findsOneWidget);
        expect(find.text(_registeredStringDefault), findsOneWidget);
        expect(find.text(_namedStringDefault), findsOneWidget);
        expect(find.text('$_floatDefault'), findsOneWidget);

        // change values
        Registrar.get<MyModel>().incrementNumber();

        await tester.pump();

        // expect updated values
        // expect(find.text('${_number + 1}'), findsOneWidget);
        expect(find.text(_stringUpdated), findsOneWidget);
        expect(find.text(_registeredStringUpdated), findsOneWidget);
        expect(find.text(_namedStringUpdated), findsOneWidget);
        expect(find.text('$_floatUpdated'), findsOneWidget);
      },
      skip: true,
    );
  });
}
