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
          return const Scaffold(
            // appBar: AppBar(),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final instance = snapshot.data;
        return Scaffold(
          // appBar: AppBar(),
          body: Stack(
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
        );
      },
    );
  }
}
