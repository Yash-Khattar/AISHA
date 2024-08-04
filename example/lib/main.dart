// Featurs of this package:
// 1. Providing calling feature widgets like chatgpt 1-1 call feature
// 2.

import 'package:flutter/material.dart';
import 'package:aisha/aisha.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Speech Widgets Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VoiceCallPage(),
    );
  }
}
