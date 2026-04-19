import 'package:flutter/material.dart';

void main() => runApp(VikasMahashaktiApp());

class VikasMahashaktiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Color(0xFFFFF3E0), // भगवा बैकग्राउंड
      ),
      home: WelcomeScreen(),
    );
  }
}

// १. स्वागत स्क्रीन (🙏 हरि ॐ जी 🙏)
class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminDashboard()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("🙏 हरि ॐ जी 🙏", style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("स्वागत है विकास पासोरिया ऑफिशियल एप में", 
              textAlign: TextAlign.center, 
              style: TextStyle(fontSize: 20, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

// २. एडमिन डैशबोर्ड (सब कुछ यहीं से कंट्रोल होगा)
class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("एडमिन कंट्रोल पैनल"), 
        backgroundColor: Colors.orange[900],
        foregroundColor: Colors.white,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(15),
        children: [
          _menuItem(Icons.receipt_long, "रशीद/डोनेशन"),
          _menuItem(Icons.event_available, "प्रोग्राम अपडेट"),
          _menuItem(Icons.account_balance, "संस्था जानकारी"),
          _menuItem(Icons.qr_code_2, "UPI/QR सेटिंग"),
          _menuItem(Icons.badge, "ID कार्ड मेकर"),
          _menuItem(Icons.post_add, "फोटो/वीडियो पोस्ट"),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // यहाँ हर बटन का अलग पेज खुलेगा जहाँ तू एडिट कर सके सै
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 55, color: Colors.orange[800]),
            SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
