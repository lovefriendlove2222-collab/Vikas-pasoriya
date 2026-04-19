import 'package:flutter/material.dart';

void main() => runApp(VikasOfficialApp());

class VikasOfficialApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange, scaffoldBackgroundColor: Color(0xFFFFF3E0)),
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
            Text("स्वागत है विकास पासोरिया ऑफिशियल एप में", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

// २. एडमिन डैशबोर्ड (सारे फंक्शन्स)
class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("एडमिन कंट्रोल पैनल"), backgroundColor: Colors.orange[900]),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(15),
        children: [
          _menuItem(Icons.receipt, "रशीद/डोनेशन"),
          _menuItem(Icons.event, "प्रोग्राम अपडेट"),
          _menuItem(Icons.business, "संस्था जानकारी"),
          _menuItem(Icons.qr_code, "UPI/QR सेटिंग"),
          _menuItem(Icons.badge, "ID कार्ड मेकर"),
          _menuItem(Icons.admin_panel_settings, "एडमिन मैनेजर"),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {}, // यहाँ तू खुद एडिट कर पावेगा
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.orange[800]),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
