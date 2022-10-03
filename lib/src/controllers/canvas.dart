import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:multi_touch/src/classes/canvas_object.dart';

/// Control the canvas and the objects on it
class CanvasController {
  /// Controller for the stream output
  final _controller = StreamController<CanvasController>();

  /// Reference to the stream to update the UI
  Stream<CanvasController> get stream => _controller.stream;

  /// Emit a new event to rebuild the UI
  void add([CanvasController? val]) => _controller.add(val ?? this);

  /// Stop the stream and finish
  void close() {
    _controller.close();
    focusNode.dispose();
  }

  /// Start the stream
  void init() => add();

  // -- Canvas Objects --

  final List<CanvasObject<Widget>> _objects = [];

  /// Current Objects on the canvas
  List<CanvasObject<Widget>> get objects => _objects;

  /// Add an object to the canvas
  void addObject(CanvasObject<Widget> value) => _update(() {
        _objects.add(value);
      });

  /// Add an object to the canvas
  void updateObject(int i, CanvasObject<Widget> value) => _update(() {
        _objects[i] = value;
      });

  /// Remove an object from the canvas
  void removeObject(int i) => _update(() {
        _objects.removeAt(i);
      });

  /// Focus node for listening for keyboard shortcuts
  final focusNode = FocusNode();

  /// Raw events from keys pressed
  void rawKeyEvent(BuildContext context, RawKeyEvent key) {}

  /// Called every time a new finger touches the screen
  void addTouch(int pointer, Offset offsetVal, Offset globalVal) {
    offset = offsetVal;
  }

  /// Called when any of the fingers update position
  void updateTouch(int pointer, Offset offsetVal, Offset globalVal) {
    offset = offsetVal;
  }

  /// Called when a finger is removed from the screen
  void removeTouch(int pointer) {}

  /// Checks if the shift key on the keyboard is pressed
  bool shiftPressed = false;

  /// Scale of the canvas
  double get scale => _scale;
  double _scale = 1;
  set scale(double value) => _update(() {
        _scale = value;
      });

  /// Max possible scale
  static const double maxScale = 3.0;

  /// Min possible scale
  static const double minScale = 0.2;

  /// How much to scale the canvas in increments
  static const double scaleAdjust = 0.05;

  /// Current offset of the canvas
  Offset get offset => _offset;
  Offset _offset = Offset.zero;
  set offset(Offset value) => _update(() {
        _offset = value;
      });

  void _update(void Function() action) {
    action();
    add(this);
  }

  static const double _scaleDefault = 1;
  static const Offset _offsetDefault = Offset.zero;

  void reset() {
    scale = _scaleDefault;
    offset = _offsetDefault;
  }

  void zoomIn() {
    scale += scaleAdjust;
  }

  void zoomOut() {
    scale -= scaleAdjust;
  }
}
