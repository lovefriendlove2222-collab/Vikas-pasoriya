import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // यह लाइन आपके एरर को ठीक करेगी
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primarySwatch: Colors.orange),
    home: LoginScreen(),
  ));
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  bool isLoading = false;

  void login() async {
    setState(() => isLoading = true);
    var db = FirebaseFirestore.instance;
    var doc = await db.collection("users").doc(phoneController.text).get();

    if (!doc.exists) {
      await db.collection("users").doc(phoneController.text).set({
        "mobile": phoneController.text,
        "approved": false,
        "role": "user", // डिफ़ॉल्ट रोल
      });
      showMsg("रजिस्ट्रेशन सफल! एडमिन के अप्रूवल का इंतज़ार करें।");
    } else {
      if (doc['role'] == 'admin') {
        // अगर एडमिन है तो सीधे होम पर (जहाँ से वो कंट्रोल कर सके)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(phoneController.text, isAdmin: true)));
      } else if (doc['approved'] == true) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(phoneController.text, isAdmin: false)));
      } else {
        showMsg("आपका अकाउंट अभी अप्रूव नहीं हुआ है।");
      }
    }
    setState(() => isLoading = false);
  }

  showMsg(msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("विकास पासोरिया ऑफिशियल", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
            SizedBox(height: 30),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: "मोबाइल नंबर", border: OutlineInputBorder())),
            SizedBox(height: 20),
            isLoading ? CircularProgressIndicator() : ElevatedButton(
              onPressed: login,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text("लॉगिन / रजिस्ट्रेशन", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
