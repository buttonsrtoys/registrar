# registrar

![registrar logo](https://github.com/buttonsrtoys/registrar/blob/main/assets/RegistrarLogo.png)

A Flutter hybrid locator that locates both single services (similar to GetIt) and inherited models (similar to Provider, InheritedWidget). Supports migrating inherited models to single services.

Registrar goals:
- Locate single services from anywhere.
- Locate inherited models in the widget tree.
- Support lazy loading.
- Support migrating an inherited model to a single service.
- Work alone or with other state management packages (RxDart, Provider, GetIt, ...).
- Be scalable and performant, so suitable for both indy and production apps.

## Single Services

Single services are those services where you only need one of them and need to locate them from anywhere in the widget tree.

To add a single service to the registry, give a builder to a "Registrar" widget and add it to the widget tree:

```dart
Registrar<MyModel>(
  builder: () => MyModel(),
  child: MyWidget(),
);
```

## Inherited Models 

Inherited models are located on the widget tree (similar to Provider, InheritedWidget). Unlike single services, you can add as many inherited models as you need.

Adding inherited models to the widget tree uses the same Registrar widget, but with the `inherited` parameter:

```dart
Registrar<MyModel>(
  builder: () => MyModel(),
  inherited: true,
  child: MyWidget(),
);
```

Registrar widgets unregister their services and models when they are removed from the widget tree. If their services and models are ChangeNotifiers, the Registrar widgets optionally call the ChangeNotifiers' `dispose` method.

## How to Locate Single Services

The single service instance can located from anywhere by type:

```dart
final myModel = Registrar.get<MyModel>();
```

If more than one instance of a model of the same type is needed, you can specify a unique name:

```dart
Registrar<MyModel>(
  builder: () => MyModel(),
  name: 'some unique name',
  child: MyWidget(),
);
```

And then get the model by type and name:

```dart
final myModel = Registrar.get<MyModel>(name: 'some unique name');
```

Unlimited Registrar widgets can be added to the widget tree. If you want to manage multiple models with a single widget, use MultiRegistrar:

```dart
MultiRegistrar(
  delegates: [
    RegistrarDelegate<MyModel>(builder: () => MyModel()),
    RegistrarDelegate<MyOtherModel>(builder: () => MyOtherModel()),
  ],
  child: MyWidget(),
);
```

For rare use cases where you need to directly manage registering and unregistering models (instead of letting Registrar and MultiRegistrar manage your models), you can use the static `register` and `unregister` functions:

````dart
Registrar.register<MyModel>(builder: () => MyModel(''))
````

## How to Located Inherited Models

Registrar implements the observer pattern as a mixin that can my added to your models and widgets.

```dart
class MyModel with Observer {
  int counter;
}
```

Models and widgets that use Observer can `listenTo` registered single services:

```dart
final text = listenTo<MyWidgetViewModel>(listener: myListener).text;
```

And `listenTo` inherited models on the widget tree. (Just add the `context` parameter to search the widget tree instead of the registry):

```dart
final text = listenTo<MyWidgetViewModel>(context: context, listener: myListener).text;
```

For convenience, Observer also adds a `get` function that doesn't required the preceding Registrar class name. Models and widgets that use Observer can get registered single services:

```dart
final text = get<MyModel>().text;
```

And get inherited models:

```dart
final text = get<MyModel>(context: context).text;
```

# Migrating an Inherited Model to a Registered Service

To make an inherited model on the widget tree visible to widgets on another branch, register the inherited model as a single service:

```dart
register<MyModel>(context);
```

After registering, the model will be available both on the widget tree and in the registry. When no longer needed in the registry, simply unregister it:

```dart
unregister<MyModel>(context);
```

# Example
(The source code for this example is under the Pub.dev "Example" tab and in the GitHub `example/lib/main.dart` file.)

There are three registered services:
1. ColorNotifier changes its color every N seconds and then calls `notifyListeners`.
2. FortyTwoService holds a number that is equal to 42.
3. RandomService generates a random number.

The first service was added to the widget tree with `Registrar`. The remaining services were added with `MultiRegistrar`.

![example](https://github.com/buttonsrtoys/registrar/blob/main/example/example.gif)

## That's it! 

If you have questions or suggestions on anything Registrar, please do not hesitate to contact me.

