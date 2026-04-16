import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primarySwatch: Colors.red),
    home: VikasHomePage(),
  ));
}

class VikasHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vikas Pasoria App")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle, size: 80, color: Colors.red),
            SizedBox(height: 20),
            Text("नमस्ते विकास भाई!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("आपका ऐप अब तैयार हो रहा है..."),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {}, 
              child: Text("Admin Login"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
