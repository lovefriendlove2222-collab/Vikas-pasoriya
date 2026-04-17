import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_panel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase चालू करना जरूरी है
  runApp(const VikasApp());
}

class VikasApp extends StatelessWidget {
  const VikasApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        textTheme: GoogleFonts.hindTextTheme(),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fort_rounded, size: 100, color: Colors.deepOrange),
            const SizedBox(height: 20),
            const Text('हरि ॐ जी!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            const Text('स्वागत है विकास पासोरिया ऑफिसियल एप में', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
              child: const Text('लॉगिन / रजिस्टर करें', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLogin())),
              child: const Text('एडमिन लॉगिन', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameC = TextEditingController();
  final _villageC = TextEditingController();
  final _mobileC = TextEditingController();
  final _workC = TextEditingController();

  Future<void> _saveUser() async {
    if (_nameC.text.isEmpty || _mobileC.text.isEmpty) return;
    await FirebaseFirestore.instance.collection('users').add({
      'name': _nameC.text,
      'village': _villageC.text,
      'mobile': _mobileC.text,
      'work': _workC.text,
      'status': 'active',
      'joinedAt': DateTime.now(),
    });
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Dashboard(name: _nameC.text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('नया रजिस्ट्रेशन')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(controller: _nameC, decoration: const InputDecoration(labelText: 'आपका नाम')),
            TextField(controller: _villageC, decoration: const InputDecoration(labelText: 'गाँव/शहर')),
            TextField(controller: _mobileC, decoration: const InputDecoration(labelText: 'मोबाईल नम्बर (यही आपका ID होगा)')),
            TextField(controller: _workC, decoration: const InputDecoration(labelText: 'क्या काम करते है')),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _saveUser, child: const Text('रजिस्टर होकर लॉगिन करें')),
          ],
        ),
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  final String name;
  const Dashboard({super.key, required this.name});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('राम-राम, $name जी'), backgroundColor: Colors.deepOrange),
      body: const Center(child: Text('यूजर डैसबोर्ड - यहाँ ID कार्ड और डोनेशन दिखेगा')),
    );
  }
}
