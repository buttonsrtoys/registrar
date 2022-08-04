# Example

A variation on the common Flutter counter project. 

There are three services:
- `ColorNotifier` changes its color every N seconds and then calls `notifyListeners`.
- `FortyTwoService` holds a number that is equal to 42.
- `RandomService` generates a random number.

The first service was added to the widget tree with `Registrar`. The remaining services are added with `MultiRegistrar`.

![example](https://github.com/buttonsrtoys/registrar/blob/main/example/example.gif)