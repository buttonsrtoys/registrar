import 'package:flutter/widgets.dart';

/// A widget that registers singletons lazily
///
/// The lifecycle of the [T] object is bound to this widget. The object is registered when this widget is added to the
/// widget tree and unregistered when removed. If [T] is of type [ChangeNotifier] then its [ChangeNotifier.dispose]
/// is called when it is unregistered.
///
/// [builder] builds the [T].
/// [instance] is an instance of [T]
/// [name] is a unique name key and only needed when more than one instance is registered of the same type.
/// If registered item is ChangeNotifier, [dispose] determines if dispose function is called. Meaningless otherwise.
/// Typically, the [Registrar] widget manages the registered item, so calls dispose when the widget is removed from
/// the widget tree.
/// [child] is the child widget.
///
/// You can pass [builder] or [instance] but not both. Passing [builder] is recommended, as it makes the implementation
/// lazy. I.e., the instance will only be created the first time it is used. If you already have an instance, then
/// use [instance].
class Registrar<T extends Object> extends StatefulWidget {
  Registrar({
    this.builder,
    this.instance,
    this.name,
    this.dispose = true,
    required this.child,
    super.key,
  })  : assert(T != Object, _missingGenericError('Registrar constructor', 'Object')),
        assert(builder == null ? instance != null : instance == null, 'Must pass builder or instance.'),
        assert(instance != null && dispose == true ? instance is ChangeNotifier : true, 'Instance not ChangeNotifier');
  final T Function()? builder;
  final T? instance;
  final String? name;
  final bool dispose;
  final Widget child;

  @override
  State<Registrar<T>> createState() => _RegistrarState<T>();

  /// Register an [Object] for retrieving with [Registrar.get]
  ///
  /// [Registrar] and [MultiRegistrar] automatically call [register] and [unregister] so this function
  /// is not typically used. It is only used to manually register or unregister an [Object]. E.g., if
  /// you could register/unregister a [ValueNotifier].
  static void register<T extends Object>({T? instance, T Function()? builder, String? name}) {
    if (Registrar.isRegistered<T>(name: name)) {
      throw Exception(
        'Error: Tried to register an instance of type $T with name $name but it is already registered.',
      );
    }
    _register(type: T, instance: instance, builder: builder, name: name);
  }

  /// Register by runtimeType for when compiled type is not available.
  ///
  /// [register] is preferred. However, use when type is not known at compile time (e.g., a super-class is registering a
  /// sub-class).
  ///
  /// [instance] is registered by runtimeType return by [instance.runtimeType]
  /// [name] is a unique name key and only needed when more than one instance is registered of the same type.
  static void registerByRuntimeType({required Object instance, String? name}) {
    final runtimeType = instance.runtimeType;
    if (Registrar.isRegisteredByRuntimeType(runtimeType: runtimeType, name: name)) {
      throw Exception(
        'Error: Tried to register an instance of type $runtimeType with name $name but it is already registered.',
      );
    }
    _register(type: runtimeType, instance: instance, name: name);
  }

  static void _register({
    required Type type,
    Object? instance,
    Object Function()? builder,
    String? name,
  }) {
    if (!_registry.containsKey(type)) {
      _registry[type] = <String?, _RegistryEntry>{};
    }
    _registry[type]![name] = _RegistryEntry(type: type, builder: builder, instance: instance);
  }

  /// Unregister an [Object] so that it can no longer be retrieved with [Registrar.get]
  ///
  /// If [T] is a ChangeNotifier then its `dispose()` method is called if [dispose] is true
  static void unregister<T extends Object>({String? name, bool dispose = true}) {
    if (!Registrar.isRegistered<T>(name: name)) {
      throw Exception(
        'Error: Tried to unregister an instance of type $T with name $name but it is not registered.',
      );
    }
    _unregister(type: T, name: name, dispose: dispose);
  }

  /// Unregister by runtimeType for when compiled type is not available.
  ///
  /// [unregister] is preferred. However, use when type is not known at compile time (e.g., a super-class is
  /// unregistering a sub-class).
  ///
  /// [runtimeType] is value return by [Object.runtimeType]
  /// [name] is a unique name key and only needed when more than one instance is registered of the same type. (See
  /// [Registrar] comments for more information on [dispose]).
  /// If registered item is a ChangeNotifier, [dispose] determines whether its dispose function is called.
  static void unregisterByRuntimeType({required Type runtimeType, String? name, bool dispose = true}) {
    if (!Registrar.isRegisteredByRuntimeType(runtimeType: runtimeType, name: name)) {
      throw Exception(
        'Error: Tried to unregister an instance of type $runtimeType with name $name but it is not registered.',
      );
    }
    _unregister(type: runtimeType, name: name, dispose: dispose);
  }

  static void _unregister({required Type type, String? name, required bool dispose}) {
    final registryEntry = _registry[type]!.remove(name);
    if (_registry[type]!.isEmpty) {
      _registry.remove(type);
    }
    if (dispose && registryEntry!.instance is ChangeNotifier) {
      (registryEntry.instance as ChangeNotifier).dispose();
    }
  }

  /// Determines whether an [Object] is registered and therefore retrievable with [Registrar.get]
  static bool isRegistered<T extends Object>({String? name}) {
    assert(T != Object, _missingGenericError('isRegistered', 'Object'));
    return _registry.containsKey(T) && _registry[T]!.containsKey(name);
  }

  /// Determines whether an [Object] is registered and therefore retrievable with [Registrar.get]
  static bool isRegisteredByRuntimeType({required Type runtimeType, String? name}) {
    return _registry.containsKey(runtimeType) && _registry[runtimeType]!.containsKey(name);
  }

  /// Get a registered [T]
  static T get<T extends Object>({String? name}) {
    if (!Registrar.isRegistered<T>(name: name)) {
      throw Exception(
        'Registrar error. Tried to get an instance of type $T with name $name but it is not registered.',
      );
    }
    return _registry[T]![name]!.instance as T;
  }
}

class _RegistrarState<T extends Object> extends State<Registrar<T>> {
  @override
  void initState() {
    super.initState();
    Registrar.register<T>(instance: widget.instance, builder: widget.builder, name: widget.name);
  }

  @override
  void dispose() {
    Registrar.unregister<T>(name: widget.name, dispose: widget.dispose);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Register multiple [Object]s so they can be retrieved with [Registrar.get]
///
/// The lifecycle of each [Object] is bound to this widget. Each object is registered when this widget is added to the
/// widget tree and unregistered when removed. If an [Object] is of type [ChangeNotifier] then its
/// [ChangeNotifier.dispose] when it is unregistered.
///
/// usage:
///   MultiRegistrar(
///     delegates: [
///       RegistrarDelegate<MyService>(builder: () => MyService()),
///       RegistrarDelegate<MyOtherService>(builder: () => MyOtherService()),
///     ],
///     child: MyWidget(),
///   );
///
class MultiRegistrar extends StatefulWidget {
  const MultiRegistrar({
    required this.delegates,
    required this.child,
    super.key,
  });

  final List<RegistrarDelegate> delegates;
  final Widget child;

  @override
  State<MultiRegistrar> createState() => _MultiRegistrarState();
}

class _MultiRegistrarState extends State<MultiRegistrar> {
  @override
  void initState() {
    super.initState();
    for (final delegate in widget.delegates) {
      delegate._register();
    }
  }

  @override
  void dispose() {
    for (final delegate in widget.delegates) {
      delegate._unregister();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Delegate for [Registrar]. See [MultiRegistrar] for more information.
///
/// [builder] builds the [Object].
/// [instance] is an instance of [T]
/// [name] is a unique name key and only needed when more than one instance is registered of the same type.
/// If registered item is a ChangeNotifier, [dispose] determines whether its dispose function is called. (See
/// [Registrar] comments for more information on [dispose]).
///
/// See [Registrar] for the difference between using [builder] and [instance]
class RegistrarDelegate<T extends Object> {
  RegistrarDelegate({
    this.builder,
    this.instance,
    this.name,
    this.dispose = true,
  }) : assert(T != Object, _missingGenericError('RegistrarDelegate constructor', 'Object'));

  final T Function()? builder;
  final String? name;
  final T? instance;
  final bool dispose;

  void _register() {
    Registrar.register<T>(instance: instance, builder: builder, name: name);
  }

  void _unregister() {
    Registrar.unregister<T>(name: name, dispose: dispose);
  }
}

/// A lazy registry entry
///
/// [instance] is a value of type [T]
/// [builder] is a function that builds [instance]
///
/// The constructor can receive either [instance] or [builder] but not both. Passing [builder] is recommended as it
/// makes the implementation lazy. I.e., [builder] is executed on the first get.
class _RegistryEntry {
  _RegistryEntry({
    required Type type,
    this.builder,
    Object? instance,
  })  : _instance = instance,
        assert(type != Object, _missingGenericError('Registrar constructor', 'Object')),
        assert(builder == null ? instance != null : instance == null);
  final Object Function()? builder;
  Object? _instance;
  Object get instance => _instance == null ? _instance = builder!() : _instance!;
}

final _registry = <Type, Map<String?, _RegistryEntry>>{};

String _missingGenericError(String function, String type) =>
    'Missing generic error: "$function" called without a custom subclass generic. Did you call '
    '"$function(..)" instead of "$function<$type>(..)"?';
