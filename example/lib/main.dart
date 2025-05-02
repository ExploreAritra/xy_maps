import 'package:example/src/example_app.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const XYMapExampleApp());
}

class XYMapExampleApp extends StatelessWidget {
  const XYMapExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XY Map Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ExampleApp(),
    );
  }
}
