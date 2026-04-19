import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const VikasOfficialApp());

class VikasOfficialApp extends StatelessWidget {
  const VikasOfficialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFFFF3E0),
      ),
      home: const RoleSelectionScreen(),
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vikas Pasoriya Official"),
        backgroundColor: Colors.orange[900],
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("🙏 HARI OM JI 🙏", 
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            _buildButton(context, "USER DASHBOARD", Colors.orange, const UserScreen()),
            const SizedBox(height: 20),
            _buildButton(context, "ADMIN LOGIN", Colors.red[900]!, const AdminLogin()),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Color color, Widget page) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(280, 60),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      child: Text(text, style: const TextStyle(fontSize: 18)),
    );
  }
}

// बाकी का यूजर और एडमिन कोड इसके नीचे जुड़ा रहेगा...
// (मशीन को खुश रखने के लिए मैंने यहाँ सिर्फ स्ट्रक्चर दिया है)
class UserScreen extends StatelessWidget { const UserScreen({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("User Page"))); }
class AdminLogin extends StatelessWidget { const AdminLogin({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Admin Login"))); }
