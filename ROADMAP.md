## Rename package to Locator?

Would make it clearer that its a Service Locator.

Could also add Provider-like functionality. So, 

    ServiceRegistrar
    ServiceProvider
    NotifierRegistrar
    NotifierProvider

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