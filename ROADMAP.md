## Optionally use InheritedWidget (like Provider) instead of Registrar

Add ChangeNotifier functionality as an alternative to locator. So, can use scoped model or
located model.

    // locator
    Registrar(
      builder: () => Cloud(),
      child: Blah(),
    );
          :
    final userNotifier = get<Cloud>().user;
    final user = listenTo<Cloud>(context: context).value;
    final user = listenTo<Property<User>>(notifier: get<Cloud>().user).value;

    // scoped
    Registrar(
      builder: () => Cloud(),
      scoped: true,
      child: Blah(),
    );
          :
    final cloud = context.get<Cloud>();
    final user = context.listenTo<Cloud>().user.value;
    final user = listenTo<Property<User>>(notifier: context.get<Cloud>().user).value;

    Could add decent error checking to above. E.g., if added context and not found, could check to 
    see if in registry and notify developer.

I *think* we won't use dependOnInheritedWidgetOfExactType (i.e., no static "of" getter) to set up
dependencies and instead use getElementForInheritedWidgetOfExactType for "get" and "listenTo". So,
maybe don't create a "RegisteredNotifier.of" function and set
"updateShouldNotify(oldWidget) => false;".

Hmm. How to use get<Cloud>(context: context) inside ViewModel, which doesn't have context? I suppose
we could add context to Model. So, "builder" sets Model.context.

Maaaaybe, have command to register inherited notifiers temporarily. E.g., when Navigator.push
used and widget on other branch needs to access temporarily. Hmmm. Could just use
Registrar.(un)register, so probably should defer this until needed.

    context.register<MyInheritedNotifier>();
    await Navigator.push(MyEditPage());
    Registrar.unregister<MyInheritedNotifier>();

    or

    Registrar.register<MyInheritedNotifier>(instance: context.get<MyInheritedNotifier>());
    await Navigator.push(MyEditPage());
    Registrar.unregister<MyInheritedNotifier>();

## Add registry output for debugging

When a registry lookup fails, it would be handy to dump the closest matches. E.g., With same type or
with different type but same name.

This would be a change to Registrar.

## Rename package to Locator?

Would make it clearer that its a Service Locator.

"of" function would be for Locator.

    Locator.of<User>(context);

Also have state "get" function that wouldn't set up the dependency.

    Locator.get<User>(context);

## Add "listenTo" functionality.

There's not a strong use case for this feature yet. Putting it here as a placeholder. One
possibility would be when the listenable ChangeNotifier is a descendant of the listening widget,
though that would be a very unusual and likely challenging use case.

Consumers of Registrar, such as `mvvm_plus`, have a `listenTo` feature that gets a
ChangeNotifier and adds a listener. Add this feature to Registrar.

So, instead of 

    Registrar.get<MyChangeNotifier>(name: myName).addListener(myListener);

We would have

    Registrar.listenTo<MyChangeNotifier>(name: myName, listener: myListener, onDispose: myDispose);

`onDispose` would be a callback for when the ChangeNotifier's dispose function is called.

## Add "maybeAddListener"?

There are no immediate needs or requests for this feature, but it's not hard to think of use
cases.

Consumers of Registrar, such as `mvvm_plus`, have a `listenTo` feature that gets a 
ChangeNotifier and adds a listener. The ChangeNotifier must exist when `listenTo` is called.

Feature: support `maybeAddListener` which add a listener if the ChangeNotifier exists. If not,
it would add the listener when the ChangeNotifier is registered. When che ChangeNotifier is 
unregistered and re-registered, the listener would be removed and added again, respectively.

Feature would require `maybeRemoveListener`.