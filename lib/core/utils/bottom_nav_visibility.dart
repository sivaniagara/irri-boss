import 'package:flutter/material.dart';

/// A global [ValueNotifier] that controls bottom navigation bar visibility.
/// Set to `false` on pages where the bottom nav should be hidden.
/// The main shell/scaffold should listen to this and hide/show accordingly.
final ValueNotifier<bool> bottomNavVisible = ValueNotifier(true);
