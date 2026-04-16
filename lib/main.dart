import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      appBar: AppBar(
        title: Text("Vikas Pasoria App"),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stars, size: 80, color: Colors.orange),
            SizedBox(height: 20),
            Text(
              "राम-राम विकास भाई!", 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
            ),
            Text("आपका ऐप अब तैयार हो रहा है..."),
          ],
        ),
      ),
    ),
  ));
}
