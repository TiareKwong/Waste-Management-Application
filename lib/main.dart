import 'package:flutter/material.dart';
import 'base_scaffold.dart';  // Import the BaseScaffold

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoWaste App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: BaseScaffold(), // Launch BaseScaffold with functional navigation
      debugShowCheckedModeBanner: false,
    );
  }
}
