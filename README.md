# registrar

`registrar` is a lazy registry that binds the lifecycles of its registered models to widgets.

`registrar` is similar to `get_it` in that it registers and unregisters models. The difference is the lifecycle of the instances are bound to its widgets `Registrar` and `MultiRegistrar`. E.g., when the `Registrar` widget is added to the widget tree, it registers its model. When it is remove from the tree, it unregisters.

`registrar` goals:
- Provide access to models from anywhere.
- Work well alone or with other state management packages (RxDart, Provider, GetIt, ...).
- Be scalable and performant, so suitable for both indy and production apps.

## Registering models

To add a model to the registry, add a `Registrar` widget to the widget tree with a builder for your model:

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

For use cases where you need to directly manage registering and unregistering models (instead of letting `Registrar` and `MultiRegistrar` manage your models), you can used the `register` and `unregister` functions:

    Registrar.register<ValueNotifier>(name: 'firstName', builder: () => ValueNotifier(''))
    Registrar.get<ValueNotifier>(name: 'firstName') = 'Sue';

## That's it! 

The [example app](https://github.com/buttonsrtoys/registrar/tree/main/example) shows much of the functionality discussed above.

If you have questions or suggestions on anything `registrar`, please do not hesitate to contact me.