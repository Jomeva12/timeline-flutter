// linked_scroll_controller.dart
import 'package:flutter/material.dart';

class LinkedScrollControllerGroup {
  LinkedScrollControllerGroup() {
    _offsetNotifier = ValueNotifier<double>(0);
  }

  late final ValueNotifier<double> _offsetNotifier;
  final _controllers = <_LinkedScrollController>[];

  ScrollController createScrollController() {
    final controller = _LinkedScrollController(this);
    _controllers.add(controller);
    return controller;
  }

  void resetScroll() {
    _offsetNotifier.value = 0;
  }

  void _updateOffset(double offset) {
    _offsetNotifier.value = offset;
    for (final controller in _controllers) {
      controller._setOffset(offset);
    }
  }
}

class _LinkedScrollController extends ScrollController {
  _LinkedScrollController(this.group) {
    super.addListener(_onScroll);
  }

  final LinkedScrollControllerGroup group;

  void _onScroll() {
    if (hasClients) {
      group._updateOffset(offset);
    }
  }

  void _setOffset(double offset) {
    if (hasClients && this.offset != offset) {
      jumpTo(offset);
    }
  }

  @override
  void dispose() {
    removeListener(_onScroll);
    super.dispose();
  }
}