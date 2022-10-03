import 'dart:math';
import 'package:flutter/material.dart';
import 'package:multi_touch/src/classes/canvas_object.dart';

void main() {
  runApp(const MyApp());
}

Color generateColor() => Color(0xFFFFFFFF & Random().nextInt(0xFFFFFFFF));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter multiple touch demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark().copyWith(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(
        title: 'MultiTouch',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final double ballRadius = 50;
  int _counter = 0;
  List<CanvasObject<Widget>> _objects = [];

  /// Current Objects on the canvas
  List<CanvasObject<Widget>> get objects => _objects;

  /// Add an object to the canvas
  void addObject(CanvasObject<Widget> value) => setState(() {
        _objects.add(value);
      });

  /// Add an object to the canvas
  void updateObject(int i, CanvasObject<Widget> value) => setState(() {
        _objects[i] = value;
      });

  /// Remove an object from the canvas
  void removeObject(int i) => setState(() {
        _objects.removeAt(i);
      });

  void removeFinger(int pointer) {
    for (final o in _objects) {
      if (o.pointer == pointer) {
        setState(() => _objects.remove(o));
        return;
      }
    }
  }

  /// Update finger offset in the canvas
  void updateFinger(int pointer, Offset off) => setState(() {
        for (final o in _objects) {
          if (o.pointer == pointer) {
            o.dx = off.dx;
            o.dy = off.dy;
            return;
          }
        }
      });

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerMove: (details) {
          // print("---move: ${details.pointer}, ${details.localPosition}, ${details.position}");
          updateFinger(details.pointer, details.localPosition);
        },
        onPointerDown: (details) {
          print("---down: ${details.pointer}, ${details.localPosition}, ${details.position}");
          Offset p = details.localPosition;

          addObject(
            CanvasObject(
              dx: p.dx,
              dy: p.dy,
              width: ballRadius,
              height: ballRadius,
              pointer: details.pointer,
              child: Container(
                decoration: BoxDecoration(
                  color: generateColor(),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
        onPointerUp: (details) {
          removeFinger(details.pointer);
          print("---up: ${details.pointer}, ${details.localPosition}, ${details.position}");
        },
        onPointerCancel: (details) {
          print("---cancel: ${details.pointer}, ${details.localPosition}, ${details.position}");
          removeFinger(details.pointer);
        },
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: SizedBox.expand(
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            child: Stack(
              children: [
                for (final object in objects)
                  AnimatedPositioned.fromRect(
                      duration: const Duration(milliseconds: 20),
                      rect: object.rect.adjusted(object.offset),
                      child: SizedBox.fromSize(
                        size: object.size,
                        child: object.child,
                      ))
              ],
            ),
          ),
          // child: Stack(
          //   children: <Widget>[
          //     const Text(
          //       'You have pushed the button this many times:',
          //     ),
          //     Text(
          //       '$_counter',
          //       style: Theme.of(context).textTheme.headline4,
          //     ),
          //   ],
          // ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

extension RectUtils on Rect {
  Rect adjusted(Offset offset) {
    return Rect.fromLTWH(offset.dx - width / 2, offset.dy - width / 2, width, height);
  }
}
