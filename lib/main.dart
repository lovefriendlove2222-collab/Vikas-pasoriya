import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.deepOrange, // प्रोफेशनल लुक के लिए
    ),
    home: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Vikas Pasoria Official"),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mic_external_on, size: 80, color: Colors.deepOrange),
            const SizedBox(height: 20),
            const Text(
              "विकास पासोरिया", 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const Text(
              "आपका ऐप तैयार हो रहा है...",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.deepOrange), // लोडिंग एनीमेशन
          ],
        ),
      ),
    ),
  ));
}
