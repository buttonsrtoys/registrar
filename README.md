# registrar

Manages a registry of services and ChangeNotifiers.

`registrar` is similar to `get_it` in that it registers and unregisters models using lazy loading. A difference is the lifecycles of the registry items are bound to its widgets `Registrar` and `MultiRegistrar`. E.g., when the `Registrar` widget is added to the widget tree, it registers its model. When it is remove from the tree, it unregisters.

`registrar` goals:
- Provide access to models from anywhere.
- Work well alone or with other state management packages (RxDart, Provider, GetIt, ...).
- Be scalable and performant, so suitable for both indy and production apps.

## Registering models

To add a model to the registry, give a builder to a `Registrar` widget and add it to the widget tree:

    Registrar<MyModel>(
      builder: () => MyModel(),
      child: MyWidget(),
    );

The model instance can retrieved from anywhere:

    final myModel = Registrar.get<MyModel>();

`Registrar` is lazy, meaning it will not build the model until its first `get`. For times where you already have your instance, you can add that to the registry directly:

    Registrar<MyModel>(
      instance: myModel,
      child: MyWidget(),
    );

If more than one instance of a model of the same type is needed, you can add a unique name:

    Registrar<MyModel>(
      builder: () => MyModel(),
      name: 'some unique name',
      child: MyWidget(),
    );

And then get the model by type and name:

    final myModel = Registrar.get<MyModel>(name: 'some unique name');

Unlimited `Registrar` widgets can be added to the widget tree. If you want to manage multiple models with a single widget, use `MultiRegistrar`:

    MultiRegistrar(
      delegates: [
        RegistrarDelegate<MyModel>(builder: () => MyModel()),
        RegistrarDelegate<MyOtherModel>(builder: () => MyOtherModel()),
      ],
      child: MyWidget(),
    );

For use cases where you need to directly manage registering and unregistering models (instead of letting `Registrar` and `MultiRegistrar` manage your models), you can use the static `register` and `unregister` functions:

    Registrar.register<MyModel>(builder: () => MyModel(''))

## That's it! 

The [example app](https://github.com/buttonsrtoys/registrar/tree/main/example) shows much of the functionality discussed above.

If you have questions or suggestions on anything `registrar`, please do not hesitate to contact me.