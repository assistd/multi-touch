import 'dart:async';

/// Control the canvas and the objects on it
class CanvasController {
  // Controller for the stream output
  final _controller = StreamController<CanvasController>();
  // Reference to the stream to update the UI
  Stream<CanvasController> get stream => _controller.stream;
  // Emit a new event to rebuild the UI
  void add([CanvasController? val]) => _controller.add(val ?? this);
  // Stop the stream and finish
  void close() => _controller.close();
// Start the stream
  void init() => add();
}
