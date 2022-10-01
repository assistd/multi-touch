import 'package:flutter/material.dart';
import 'package:multi_touch/src/controllers/canvas.dart';

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
    super.initState();
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
              Positioned(
                top: 20,
                left: 20,
                width: 100,
                height: 100,
                child: Container(color: Colors.red),
              )
            ],
          ),
        );
      },
    );
  }
}
