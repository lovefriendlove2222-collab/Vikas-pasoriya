import 'package:flutter/material.dart';

void main() => runApp(VikasMahashaktiApp());

class VikasMahashaktiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vikas Pasoriya Official',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Color(0xFFFFF3E0), // हल्का भगवा बैकग्राउंड
      ),
      home: SplashScreen(),
    );
  }
}

// --- स्वागत स्क्रीन ---
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminLogin()));
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
            SizedBox(height: 15),
            Text("स्वागत है विकास पासोरिया ऑफिशियल एप में", 
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.white70)),
            SizedBox(height: 30),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// --- एडमिन लॉगिन ---
class AdminLogin extends StatelessWidget {
  final TextEditingController user = TextEditingController();
  final TextEditingController pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("सुपर एडमिन लॉगिन"), backgroundColor: Colors.orange[800]),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: user, decoration: InputDecoration(labelText: "यूजरनेम")),
            TextField(controller: pass, decoration: InputDecoration(labelText: "पासवर्ड"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // फिलहाल डायरेक्ट एंट्री, बाद में फायरबेस से जुड़ेगा
                if(user.text == "admin" && pass.text == "Vikas1998") {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard()));
                }
              },
              child: Text("लॉगिन करें"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], foregroundColor: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}

// --- मेन डैशबोर्ड ---
class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("विकास पासोरिया एडमिन"), backgroundColor: Colors.orange[900]),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(10),
        children: [
          _card(Icons.receipt_long, "रशीद/डोनेशन"),
          _card(Icons.event_note, "प्रोग्राम अपडेट"),
          _card(Icons.groups, "मेरी संस्थाएं"),
          _card(Icons.qr_code_scanner, "UPI/QR सेटिंग"),
          _card(Icons.badge, "ID कार्ड मेकर"),
          _card(Icons.post_add, "फोटो/वीडियो पोस्ट"),
        ],
      ),
    );
  }

  Widget _card(IconData icon, String title) {
    return Card(
      color: Colors.white,
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 45, color: Colors.orange[900]),
          SizedBox(height: 10),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
