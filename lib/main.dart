import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: Text(
          "नमस्ते विकास भाई!\nविकास पासोरिया ऐप\nतैयार हो रहा है।",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  ));
}
