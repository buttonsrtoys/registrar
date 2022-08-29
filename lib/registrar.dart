import 'package:flutter/widgets.dart';

/// A widget that registers singletons lazily
///
/// The lifecycle of the [T] object is bound to this widget. The object is registered when this widget is added to the
/// widget tree and unregistered when removed. If [T] is of type [ChangeNotifier] then its [ChangeNotifier.dispose]
/// is called when it is unregistered.
///
/// [builder] builds the [T].
/// [name] is a unique name key and only needed when more than one instance is registered of the same type.
/// If object is ChangeNotifier, [dispose] determines if dispose function is called. If object is not a
/// ChangeNotifier then the value of [dispose] is ignored.
/// [child] is the child widget.
/// [inherited] is set to add an InheritedWidget to the widget so children can access with [context.get].
class Registrar<T extends Object> extends StatefulWidget {
  Registrar({
    required this.builder,
    this.name,
    this.inherited = false,
    this.dispose = true,
    super.key,
    required this.child,
  }) : assert(T != Object, _missingGenericError('constructor Registrar', 'Object'));
  final T Function()? builder;
  final String? name;
  final bool dispose;
  final bool inherited;
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

  /// [type] is not a generic because sometimes runtimeType is required.
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
  /// If object is a ChangeNotifier, [dispose] determines whether its dispose function is called. Ignored otherwise.
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
    if (dispose && registryEntry!.hasInitialized) {
      if (registryEntry.instance is ChangeNotifier) {
        (registryEntry.instance as ChangeNotifier).dispose();
      }
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
        'Registrar tried to get an instance of type $T with name $name but it is not registered.',
      );
    }
    return _registry[T]![name]!.instance as T;
  }
}

class _RegistrarState<T extends Object> extends State<Registrar<T>> {
  bool shouldBuildInheritedWidget = false;
  late _LazyInitializer<T> lazyInitializer;

  void rebuildInheritedWidget() => setState(() => shouldBuildInheritedWidget = true);

  @override
  void initState() {
    super.initState();
    if (widget.inherited) {
      lazyInitializer = _LazyInitializer<T>(widget.builder, null,
          onInitialization: (notifier) => (notifier as ChangeNotifier).addListener(rebuildInheritedWidget));
    } else {
      Registrar.register<T>(builder: widget.builder, name: widget.name);
    }
  }

  @override
  void dispose() {
    // Rich, do we need to dispose inherited change notifiers here?
    if (!widget.inherited) {
      Registrar.unregister<T>(name: widget.name, dispose: widget.dispose);
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Registrar<T> oldWidget) {
    shouldBuildInheritedWidget = false;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.inherited) {
      return _RegistrarInheritedWidget<T>(
        lazyInitializer: lazyInitializer,
        shouldRebuild: shouldBuildInheritedWidget,
        child: widget.child,
      );
    } else {
      return widget.child;
    }
  }
}

/// Adds [get] and [listenTo] features to BuildContext.
extension RegistrarBuildContextExtension on BuildContext {
  /// Searches for a [Registrar] widget with [inherited] param set and a model of type [T].
  ///
  /// usage:
  ///
  ///     final myService = context.get<MyService>();
  ///
  /// The search is for the first match up the widget tree from the calling widget.
  /// This does not set up a dependency between the InheritedWidget and the context. For that, use [listenTo].
  /// Performs a lazy initialization if necessary. Throws exception of widget not found.
  /// For those familiar with Provider, [get] is effectively `Provider.of<MyModel>(listen: false);`.
  T get<T extends Object>() {
    final inheritedElement = getElementForInheritedWidgetOfExactType<_RegistrarInheritedWidget<T>>();
    if (inheritedElement == null) {
      throw Exception('No inherited Registrar widget found with type $T');
    }
    final widget = inheritedElement.widget as _RegistrarInheritedWidget<T>;
    return widget.instance;
  }

  /// Searches for a [Registrar] widget with [inherited] param set and a model of type [T] and creates dependency.
  ///
  /// usage:
  ///
  ///     final myModel = context.listenTo<MyModel>();
  ///
  /// The search is for the first match up the widget tree from the calling widget.
  /// Sets up a dependency between the [Registrar] widget and the context. For no dependency, use [get].
  /// Performs a lazy initialization if necessary. Throws exception of widget not found.
  /// For those familiar with Provider, [listenTo] is effectively `Provider.of<MyModel>();`.
  /// An exception is thrown if [T] is not a [ChangeNotifier].
  T listenTo<T extends ChangeNotifier>({VoidCallback? listener}) {
    final _RegistrarInheritedWidget<T>? inheritedWidget =
        dependOnInheritedWidgetOfExactType<_RegistrarInheritedWidget<T>>();
    assert(inheritedWidget != null, 'No inherited Registrar found in context');
    return inheritedWidget!.instance;
  }
}

/// Manages lazy initialization.
class _LazyInitializer<T extends Object> {
  /// Can receive a builder or an instance but not both.
  ///
  /// [_builder] builds the instance. In cases where object is already initialized, pass [_instance].
  /// [onInitialization] is called after the call to [_builder].
  _LazyInitializer(this._builder, this._instance, {this.onInitialization})
      : assert(_builder == null ? _instance != null : _instance == null, 'Can only pass builder or instance.');
  final T Function()? _builder;
  T? _instance;
  final void Function(T)? onInitialization;
  bool get hasInitialized => _instance != null;
  T get instance {
    if (_instance == null) {
      _instance = _builder!();
      if (onInitialization != null) {
        onInitialization!(_instance!);
      }
    }
    return _instance!;
  }
}

/// Optional InheritedWidget class.
///
/// updateShouldNotify always returns true, so all dependent childer build when
/// If [T] is a ChangeNotifier, [changeNotifierListener] is added a listener. Typically, this listener just calls setState to
/// rebuild.
class _RegistrarInheritedWidget<T extends Object> extends InheritedWidget {
  const _RegistrarInheritedWidget({
    Key? key,
    required this.lazyInitializer,
    required this.shouldRebuild,
    required Widget child,
  }) : super(key: key, child: child);

  final _LazyInitializer<T> lazyInitializer;
  final bool shouldRebuild;

  T get instance => lazyInitializer.instance;

  @override
  bool updateShouldNotify(_RegistrarInheritedWidget oldWidget) => shouldRebuild;
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
/// If object is a ChangeNotifier, [dispose] determines whether its dispose function is called. (See
/// [Registrar] comments for more information on [dispose]).
///
/// See [Registrar] for the difference between using [builder] and [instance]
class RegistrarDelegate<T extends Object> {
  RegistrarDelegate({
    this.builder,
    this.instance,
    this.name,
    this.dispose = true,
  }) : assert(T != Object, _missingGenericError('constructor RegistrarDelegate', 'Object'));

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
/// [type] is not a generic because something need to determine at runtime (e.g., runtimeType).
///
/// The constructor can receive either [instance] or [builder] but not both. Passing [builder] is recommended as it
/// makes the implementation lazy. I.e., [builder] is executed on the first get.
// Rich, probably makes sense to pass _LazyInitialize instead. Do a general pass through the code for this after
// writing more tests.
class _RegistryEntry {
  _RegistryEntry({
    required Type type,
    Object Function()? builder,
    Object? instance,
  })  : assert(type != Object, _missingGenericError('constructor _RegistrarEntry', 'Object')),
        assert(builder == null ? instance != null : instance == null) {
    _lazyInitializer = _LazyInitializer(builder, instance);
  }
  late final _LazyInitializer _lazyInitializer;
  bool get hasInitialized => _lazyInitializer.hasInitialized;
  Object get instance => _lazyInitializer.instance;
}

final _registry = <Type, Map<String?, _RegistryEntry>>{};

String _missingGenericError(String function, String type) =>
    'Missing generic. The function "$function" was called without a custom subclass generic. Did you call '
    '"$function(..)" instead of "$function<$type>(..)"?';
