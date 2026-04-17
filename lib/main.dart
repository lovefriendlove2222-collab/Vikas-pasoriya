import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
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

// 1. स्वागत स्क्रीन
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
          ],
        ),
      ),
    );
  }
}

// 2. रजिस्ट्रेशन और यूजर डेटा (आईडी कार्ड के लिए)
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '', village = '', city = '', mobile = '', work = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('नया रजिस्ट्रेशन (ID कार्ड)'), backgroundColor: Colors.deepOrange),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(decoration: const InputDecoration(labelText: 'आपका नाम'), onChanged: (v) => name = v),
              TextFormField(decoration: const InputDecoration(labelText: 'गाँव'), onChanged: (v) => village = v),
              TextFormField(decoration: const InputDecoration(labelText: 'शहर'), onChanged: (v) => city = v),
              TextFormField(decoration: const InputDecoration(labelText: 'मोबाईल नम्बर'), keyboardType: TextInputType.phone, onChanged: (v) => mobile = v),
              TextFormField(decoration: const InputDecoration(labelText: 'क्या काम करते है'), onChanged: (v) => work = v),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard(userName: name))),
                child: const Text('रजिस्टर होकर डैसबोर्ड देखें', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 3. डैसबोर्ड (सभी फीचर्स के साथ)
class Dashboard extends StatelessWidget {
  final String userName;
  const Dashboard({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('राम-राम, $userName जी'), backgroundColor: Colors.deepOrange),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(decoration: const BoxDecoration(color: Colors.deepOrange), child: Text('विकास पासोरिया ऑफिसियल', style: const TextStyle(color: Colors.white, fontSize: 24))),
            ListTile(leading: const Icon(Icons.qr_code), title: const Text('डोनेशन QR'), onTap: () {}),
            ListTile(leading: const Icon(Icons.badge), title: const Text('मेरा ID कार्ड'), onTap: () {}),
            ListTile(leading: const Icon(Icons.admin_panel_settings), title: const Text('एडमिन लॉगिन'), onTap: () {}),
            ListTile(leading: const Icon(Icons.logout), title: const Text('लोग आउट'), onTap: () => Navigator.popUntil(context, (route) => route.isFirst)),
          ],
        ),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(15),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          _card('योजनाएं', Icons.list_alt, Colors.orange),
          _card('रसीद डाउनलोड', Icons.receipt_long, Colors.blue),
          _card('यूट्यूब', Icons.play_circle, Colors.red),
          _card('UPI/QR', Icons.account_balance_wallet, Colors.green),
          _card('संस्था जानकारी', Icons.business, Colors.purple),
          _card('प्रोग्राम अपडेट', Icons.event, Colors.brown),
        ],
      ),
    );
  }

  Widget _card(String title, IconData icon, Color color) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
