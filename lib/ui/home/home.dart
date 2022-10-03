import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:multi_touch/src/controllers/canvas.dart';
import 'package:multi_touch/src/classes/canvas_object.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = CanvasController();

  @override
  void initState() {
    _controller.init();
    _dummyData();
    super.initState();
  }

  void _dummyData() {
    _controller.addObject(
      CanvasObject(
        dx: 20,
        dy: 20,
        width: 50,
        height: 50,
        child: Container(color: Colors.blue),
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CanvasController>(
      stream: _controller.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final instance = snapshot.data;
        return Scaffold(
          // appBar: AppBar(
          //   actions: [
          //     IconButton(
          //       tooltip: 'Zoom In',
          //       icon: const Icon(Icons.zoom_in),
          //       onPressed: _controller.zoomIn,
          //     ),
          //     IconButton(
          //       tooltip: 'Zoom Out',
          //       icon: const Icon(Icons.zoom_out),
          //       onPressed: _controller.zoomOut,
          //     ),
          //     IconButton(
          //       tooltip: 'Reset the Scale and Offset',
          //       icon: const Icon(Icons.restore),
          //       onPressed: _controller.reset,
          //     ),
          //   ],
          // ),
          body: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerSignal: (details) {
              if (details is PointerScrollEvent) {
                GestureBinding.instance.pointerSignalResolver.register(details, (event) {
                  if (event is PointerScrollEvent) {
                    if (_controller.shiftPressed) {
                      double zoomDelta = (-event.scrollDelta.dy / 300);
                      _controller.scale = _controller.scale + zoomDelta;
                    } else {
                      _controller.offset = _controller.offset - event.scrollDelta;
                    }
                  }
                });
              }
            },
            onPointerMove: (details) {
              print("---move: ${details.pointer}, ${details.localPosition}, ${details.position}");
              _controller.updateTouch(
                details.pointer,
                details.localPosition,
                details.position,
              );
            },
            onPointerDown: (details) {
              print("---down: ${details.pointer}, ${details.localPosition}, ${details.position}");
              _controller.addTouch(
                details.pointer,
                details.localPosition,
                details.position,
              );
            },
            onPointerUp: (details) {
              print("---up: ${details.pointer}, ${details.localPosition}, ${details.position}");
              _controller.removeTouch(details.pointer);
            },
            onPointerCancel: (details) {
              print("---cancel: ${details.pointer}, ${details.localPosition}, ${details.position}");
              _controller.removeTouch(details.pointer);
            },
            child: RawKeyboardListener(
              autofocus: true,
              focusNode: _controller.focusNode,
              onKey: (key) => _controller.rawKeyEvent(context, key),
              child: SizedBox.expand(
                child: Stack(
                  children: [
                    for (final object in instance!.objects)
                      AnimatedPositioned.fromRect(
                        duration: const Duration(milliseconds: 20),
                        rect: object.rect.adjusted(_controller.offset),
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: SizedBox.fromSize(
                            size: object.size,
                            child: object.child,
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

extension RectUtils on Rect {
  Rect adjusted(Offset offset) {
    return Rect.fromLTWH(offset.dx - width / 2, offset.dy - width / 2, width, height);
  }
}
