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
        width: 100,
        height: 100,
        child: Container(color: Colors.red),
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
          appBar: AppBar(),
          body: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerSignal: (details) {
              if (details is PointerScrollEvent) {
                GestureBinding.instance.pointerSignalResolver.register(details,
                    (event) {
                  if (event is PointerScrollEvent) {
                    if (_controller.shiftPressed) {
                      double zoomDelta = (-event.scrollDelta.dy / 300);
                      _controller.scale = _controller.scale + zoomDelta;
                    } else {
                      _controller.offset =
                          _controller.offset - event.scrollDelta;
                    }
                  }
                });
              }
            },
            onPointerMove: (details) {
              _controller.updateTouch(
                details.pointer,
                details.localPosition,
                details.position,
              );
            },
            onPointerDown: (details) {
              _controller.addTouch(
                details.pointer,
                details.localPosition,
                details.position,
              );
            },
            onPointerUp: (details) {
              _controller.removeTouch(details.pointer);
            },
            onPointerCancel: (details) {
              _controller.removeTouch(details.pointer);
            },
            child: RawKeyboardListener(
              autofocus: true,
              focusNode: _controller.focusNode,
              onKey: (key) => _controller.rawKeyEvent(context, key),
              child: Stack(
                children: [
                  for (final object in instance!.objects)
                    Positioned(
                      top: object.dy,
                      left: object.dx,
                      width: object.width,
                      height: object.height,
                      child: object.child!,
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
