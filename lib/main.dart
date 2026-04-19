import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(VikasMahashaktiApp());

class VikasMahashaktiApp extends StatelessWidget {
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
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
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
            Text("विकास पासोरिया ऑफिशियल एप", style: TextStyle(fontSize: 22, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

// २. एडमिन लॉगिन और पासवर्ड मैनेजमेंट
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _passController = TextEditingController();
  String? savedPassword;

  @override
  void initState() {
    super.initState();
    _loadPassword();
  }

  _loadPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedPassword = prefs.getString('admin_pass') ?? "Vikas1998"; // डिफ़ॉल्ट पासवर्ड
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("एडमिन लॉगिन")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _passController, decoration: InputDecoration(labelText: "पासवर्ड दर्ज करें"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_passController.text == savedPassword) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminDashboard()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("गलत पासवर्ड भाई!")));
                }
              },
              child: Text("प्रवेश करें"),
            )
          ],
        ),
      ),
    );
  }
}

// ३. एडमिन डैशबोर्ड
class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("विकास पासोरिया एडमिन पैनल"), backgroundColor: Colors.orange[900]),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(15),
        children: [
          _menuItem(context, Icons.play_circle_fill, "यूट्यूब अपडेट", UpdateDataPage("यूट्यूब लिंक")),
          _menuItem(context, Icons.edit, "जानकारी बदलें", UpdateDataPage("एप की जानकारी")),
          _menuItem(context, Icons.lock_reset, "पासवर्ड बदलें", ChangePasswordPage()),
          _menuItem(context, Icons.cloud_upload, "डाटा जोड़ें", UpdateDataPage("नया डाटा")),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, Widget page) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, size: 50, color: Colors.orange[900]), Text(title, style: TextStyle(fontWeight: FontWeight.bold))],
        ),
      ),
    );
  }
}

// ४. पासवर्ड बदलने का पेज
class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _newPass = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("नया पासवर्ड सैट करें")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _newPass, decoration: InputDecoration(labelText: "नया पासवर्ड लिखें")),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('admin_pass', _newPass.text);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("पासवर्ड बदल गया भाई!")));
                Navigator.pop(context);
              },
              child: Text("सेव करें"),
            )
          ],
        ),
      ),
    );
  }
}

// ५. जनरल डाटा अपडेट पेज
class UpdateDataPage extends StatelessWidget {
  final String title;
  UpdateDataPage(this.title);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$title अपडेट करें")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(maxLines: 3, decoration: InputDecoration(hintText: "$title यहाँ दर्ज करें...", border: OutlineInputBorder())),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("अपडेट करें")),
          ],
        ),
      ),
    );
  }
}
