import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(color: Colors.orange[50]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("🙏 लॉगिन करें 🙏", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange[900])),
            SizedBox(height: 30),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "मोबाइल नम्बर", prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()),
            ),
            SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "पॉसवर्ड", prefixIcon: Icon(Icons.lock), border: OutlineInputBorder()),
            ),
            SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[900]),
                onPressed: () {
                  // लॉगिन लॉजिक यहाँ आएगा
                },
                child: Text("प्रवेश करें", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
