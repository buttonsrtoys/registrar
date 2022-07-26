# package example

A twist on the common Flutter counter project. 

## Description

Increments a counter by pressing the floating action button (FAB).

There are three services:
- `ColorNotifier` changes its color every N seconds and then calls `notifyListeners`.
- `FortyTwoService` holds a number that is equal to 42.
- `RandomService` generates a random number.

The first service added to the widget tree with `Registrar`. The remaining services are added with `MultiRegistrar`.