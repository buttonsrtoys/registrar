import 'package:flutter_test/flutter_test.dart';
import 'package:registrar/registrar.dart';

class MyModel {
  final answer = 42;
}

void main() {
  group('Registrar', () {
    test('unnamed model', () {
      expect(Registrar.isRegistered<MyModel>(), false);
      Registrar.register<MyModel>(instance: MyModel());
      expect(Registrar.isRegistered<MyModel>(), true);
      expect(Registrar.get<MyModel>().answer, 42);
      Registrar.unregister<MyModel>();
      expect(Registrar.isRegistered<MyModel>(), false);
      expect(() => Registrar.get<MyModel>(), throwsA(isA<Exception>()));
      expect(() => Registrar.unregister<MyModel>(), throwsA(isA<Exception>()));
    });

    test('named model', () {
      String name = 'Some name';
      expect(Registrar.isRegistered<MyModel>(), false);
      Registrar.register<MyModel>(instance: MyModel(), name: name);
      expect(Registrar.isRegistered<MyModel>(), false);
      expect(Registrar.isRegistered<MyModel>(name: name), true);
      expect(Registrar.get<MyModel>(name: name).answer, 42);
      Registrar.unregister<MyModel>(name: name);
      expect(Registrar.isRegistered<MyModel>(), false);
      expect(Registrar.isRegistered<MyModel>(name: name), false);
      expect(() => Registrar.get<MyModel>(name: name), throwsA(isA<Exception>()));
      expect(() => Registrar.unregister<MyModel>(name: name), throwsA(isA<Exception>()));
    });
  });
}
