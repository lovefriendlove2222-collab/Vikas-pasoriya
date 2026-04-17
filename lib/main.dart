import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase Error: $e");
  }
  runApp(const VikasApp());
}

class VikasApp extends StatelessWidget {
  const VikasApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'विकास पासोरिया ऑफिशियल',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const HomePage(),
    );
  }
}

// --- 1. होम पेज (Home Page) ---
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("विकास पासोरिया ऑफिशियल"),
        backgroundColor: Colors.orange[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => _adminLogin(context),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text("🚩 जय श्री राम 🚩", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
          const Text("लोकगायक विकास पासोरिया", style: TextStyle(fontSize: 16)),
          const Divider(height: 40),
          
          // यहाँ भविष्य में यूट्यूब वीडियोस आएंगे
          const Expanded(
            child: Center(child: Text("यहाँ आपकी ताज़ा रागनियां दिखेंगी (Coming Soon)")),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
                minimumSize: const Size(double.infinity, 55),
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistrationPage())),
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text("मेंबर रजिस्ट्रेशन", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  void _adminLogin(BuildContext context) {
    TextEditingController pass = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("एडमिन लॉगिन"),
        content: TextField(controller: pass, decoration: const InputDecoration(hintText: "पासवर्ड"), obscureText: true),
        actions: [
          TextButton(onPressed: () {
            if (pass.text == "1008@pasoriya") { // आपका पासवर्ड
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPanel()));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("गलत पासवर्ड!")));
            }
          }, child: const Text("लॉगिन"))
        ],
      ),
    );
  }
}

// --- 2. रजिस्ट्रेशन पेज ---
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _village = TextEditingController();

  void _save() async {
    if (_name.text.isEmpty || _phone.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("नाम और नंबर ज़रूरी है!")));
      return;
    }
    try {
      // 'menus' आपके Firebase फोल्डर का नाम है
      await FirebaseFirestore.instance.collection('menus').add({
        'name': _name.text,
        'phone': _phone.text,
        'village': _village.text,
        'time': DateTime.now().toString(),
      });
      if (mounted) {
        showDialog(context: context, builder: (context) => const AlertDialog(title: Text("सफल!"), content: Text("आपकी जानकारी सेव हो गई है।")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("कनेक्शन एरर: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("मेंबर रजिस्ट्रेशन")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: "आपका नाम")),
            TextField(controller: _village, decoration: const InputDecoration(labelText: "गाँव")),
            TextField(controller: _phone, decoration: const InputDecoration(labelText: "मोबाइल नंबर")),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _save, child: const Text("सबमिट करें")),
          ],
        ),
      ),
    );
  }
}

// --- 3. एडमिन पैनल (मेंबर लिस्ट देखने के लिए) ---
class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("मेंबर लिस्ट"), backgroundColor: Colors.black),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('menus').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(
            children: snapshot.data!.docs.map((doc) => ListTile(
              leading: const Icon(Icons.person),
              title: Text(doc['name'] ?? 'Unknown'),
              subtitle: Text("${doc['village'] ?? ''} - ${doc['phone'] ?? ''}"),
            )).toList(),
          );
        },
      ),
    );
  }
}
