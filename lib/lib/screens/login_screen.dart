import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();

  void handleLogin() async {
    String phone = phoneController.text;
    if (phone.isEmpty) return;

    var userDoc = await FirebaseFirestore.instance.collection('users').doc(phone).get();

    if (!userDoc.exists) {
      // नया यूजर रजिस्टर करें
      await FirebaseFirestore.instance.collection('users').doc(phone).set({
        'mobile': phone,
        'role': 'member',
        'approved': false,
        'org_id': 'default_org'
      });
      showMsg("Registration Successful. Wait for Approval.");
    } else {
      if (userDoc['approved']) {
        showMsg("Welcome back! Role: ${userDoc['role']}");
        // यहाँ से होम पेज पर भेजें
      } else {
        showMsg("Your account is pending approval.");
      }
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("VIKAS PASORIA OFFICIAL", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
            SizedBox(height: 40),
            TextField(controller: phoneController, decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Mobile Number")),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleLogin,
              child: Text("LOGIN / REGISTER"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            )
          ],
        ),
      ),
    );
  }
}
