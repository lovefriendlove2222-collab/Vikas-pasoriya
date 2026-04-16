import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase शुरू करने की कोशिश, अगर फाइल न मिले तो भी ऐप क्रैश नहीं होगा
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase logic skipped for build testing");
  }
  
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      appBar: AppBar(
        title: Text("Vikas Pasoria Official"),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              "बधाई हो विकास भाई!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text("आपका ऐप सफलतापूर्वक बन गया है।"),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              child: Text("Admin Dashboard"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            )
          ],
        ),
      ),
    ),
  ));
}
