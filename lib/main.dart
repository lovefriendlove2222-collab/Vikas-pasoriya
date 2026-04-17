import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(VikasSuperApp());

class VikasSuperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vikas Pasoriya Official',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Color(0xFFFFFAF0), // हल्का भगवा टच
        textTheme: GoogleFonts.aksharTextTheme(),
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colors.orange[900],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("🙏 हरि ॐ जी 🙏", style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("स्वागत है विकास पासोरिया ऑफिसियल एप में", 
                 textAlign: TextAlign.center,
                 style: TextStyle(fontSize: 18, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
