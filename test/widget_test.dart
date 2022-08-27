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
  required bool listenToRegistrar,
}) =>
    MaterialApp(
      home: Registrar(
        builder: () => MyModel(),
        child: MyTestWidget(listenToRegistrar: listenToRegistrar),
      ),
    );

class MyModel extends ChangeNotifier {
  int number = _number;

  final myFloatProperty = ValueNotifier<double>(_floatDefault);

  void incrementNumber() {
    number++;
    notifyListeners();
  }
}

class MyTestWidget extends StatelessWidget {
  const MyTestWidget({
    super.key,
    required bool listenToRegistrar,
  });

  @override
  Widget build(BuildContext _) {
    // final float = listenTo<Property<double>>(notifier: get<MyModel>().myFloatProperty).value;
    return Column(
      children: const <Widget>[
        Text('$_number'),
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
    testWidgets('not listening to Registrar, not registered, and not named ViewModel does not update value',
            (WidgetTester tester) async {
          await tester.pumpWidget(testApp(listenToRegistrar: false));

          expect(Registrar.isRegistered<MyModel>(), true);
          expect(find.text('$_number'), findsOneWidget);

          Registrar.get<MyModel>().incrementNumber();
          await tester.pump();

          // expect does not increment b/c not listening
          expect(find.text('$_number'), findsOneWidget);
        });

    testWidgets('listening to Registrar but not registered ViewModel shows correct values',
            (WidgetTester tester) async {
          await tester.pumpWidget(testApp(listenToRegistrar: true));

          expect(Registrar.isRegistered<MyModel>(), true);
          expect(find.text('$_number'), findsOneWidget);

          Registrar.get<MyModel>().incrementNumber();
          await tester.pump();

          expect(find.text('${_number + 1}'), findsOneWidget);
        });

    testWidgets('listening to Registrar and registered ViewModel  but not named ViewModel shows correct values',
            (WidgetTester tester) async {
          await tester.pumpWidget(testApp(listenToRegistrar: true));

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
          expect(find.text('${_number + 1}'), findsOneWidget);
          expect(find.text(_stringUpdated), findsOneWidget);
          expect(find.text(_registeredStringUpdated), findsOneWidget);
          expect(find.text(_namedStringUpdated), findsOneWidget);
          expect(find.text('$_floatUpdated'), findsOneWidget);
        });

    testWidgets('listening to Registrar, registered and named ViewModel shows correct values',
            (WidgetTester tester) async {
          await tester.pumpWidget(testApp(listenToRegistrar: true));

          expect(find.text('$_number'), findsOneWidget);

          Registrar.get<MyModel>().incrementNumber();
          await tester.pump();

          expect(find.text('${_number + 1}'), findsOneWidget);
        });
  });
}
