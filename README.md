# registrar

![registrar logo](https://github.com/buttonsrtoys/registrar/blob/main/assets/RegistrarLogo.png)

A Flutter library that manages a registry of services and ChangeNotifiers. Similar to GetIt, but binds the lifecycles of its registered objects to widgets.

Registrar registers and unregisters models using lazy loading. When Registrar widgets are added to the widget tree, they register their models. When they are removed from the tree, they unregister.

Registrar goals:
- Provide access to models from anywhere.
- Work alone or with other state management packages (RxDart, Provider, GetIt, ...).
- Be scalable and performant, so suitable for both indy and production apps.

## Registering models

To add a model to the registry, give a builder to a "Registrar" widget and add it to the widget tree:

    Registrar<MyModel>(
      builder: () => MyModel(),
      child: MyWidget(),
    );

The model instance can retrieved from anywhere by type:

    final myModel = Registrar.get<MyModel>();

Registrar is lazy, meaning it will not build the model until its first `get`. For times where you already have your instance, you can add that to the registry directly:

    Registrar<MyModel>(
      instance: myModel,
      child: MyWidget(),
    );

If more than one instance of a model of the same type is needed, you can specify a unique name:

    Registrar<MyModel>(
      builder: () => MyModel(),
      name: 'some unique name',
      child: MyWidget(),
    );

And then get the model by type and name:

    final myModel = Registrar.get<MyModel>(name: 'some unique name');

Unlimited Registrar widgets can be added to the widget tree. If you want to manage multiple models with a single widget, use MultiRegistrar:

    MultiRegistrar(
      delegates: [
        RegistrarDelegate<MyModel>(builder: () => MyModel()),
        RegistrarDelegate<MyOtherModel>(builder: () => MyOtherModel()),
      ],
      child: MyWidget(),
    );

For use cases where you need to directly manage registering and unregistering models (instead of letting Registrar and MultiRegistrar manage your models), you can use the static `register` and `unregister` functions:

    Registrar.register<MyModel>(builder: () => MyModel(''))

## Example app

The repo example shows much of the functionality discussed above. The 3 buttons each get registered services.

![example app](https://github.com/buttonsrtoys/registrar/blob/main/example/example.gif)

## That's it! 

If you have questions or suggestions on anything Registrar, please do not hesitate to contact me.