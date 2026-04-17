import 'package:flutter/material.dart';
import 'register_screen.dart'; // ऊपर वाली फाइल को यहाँ जोड़ें

void main() => runApp(VikasApp());

class VikasApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("🙏 हरि ॐ जी 🙏", style: TextStyle(fontSize: 35, color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("स्वागत है विकास पासोरिया\nऑफिसियल एप में", 
                 textAlign: TextAlign.center,
                 style: TextStyle(fontSize: 20, color: Colors.white70)),
            SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(foregroundColor: Colors.orange[900], backgroundColor: Colors.white),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
              },
              child: Text("आगे बढ़ें", style: TextStyle(fontSize: 20)),
            )
          ],
        ),
      ),
    );
  }
}
