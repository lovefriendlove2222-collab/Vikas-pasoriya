import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase connection failed: $e");
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

// --- होम पेज ---
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("विकास पासोरिया ऑफिशियल"),
        backgroundColor: Colors.orange[900],
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => _adminLogin(context),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.orange[100]!, Colors.white], begin: Alignment.topCenter),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("🚩 जय श्री राम 🚩", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.red)),
            const Text("लोकगायक विकास पासोरिया", style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistrationPage())),
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text("मेंबर रजिस्ट्रेशन", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _adminLogin(BuildContext context) {
    TextEditingController pass = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("एडमिन लॉगिन"),
        content: TextField(controller: pass, decoration: const InputDecoration(hintText: "पासवर्ड यहाँ लिखें"), obscureText: true),
        actions: [
          TextButton(
            onPressed: () {
              if (pass.text == "1008@pasoriya") {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPanel()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("गलत पासवर्ड!")));
              }
            }, 
            child: const Text("लॉगिन")
          )
        ],
      ),
    );
  }
}

// --- रजिस्ट्रेशन पेज ---
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _village = TextEditingController();

  void _saveData() async {
    if (_name.text.isEmpty || _phone.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("कृपया नाम और नंबर भरें!")));
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('menus').add({
        'name': _name.text, 'phone': _phone.text, 'village': _village.text, 'date': DateTime.now().toString(),
      });
      if (mounted) {
        showDialog(context: context, builder: (context) => AlertDialog(
          title: const Text("सफल!"), content: const Text("आपकी जानकारी सेव हो गई है।"),
          actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text("ठीक है"))],
        ));
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
            TextField(controller: _name, decoration: const InputDecoration(labelText: "नाम", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _village, decoration: const InputDecoration(labelText: "गाँव", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "मोबाइल", border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveData, child: const Text("डाटा सबमिट करें")),
          ],
        ),
      ),
    );
  }
}

// --- एडमिन पैनल ---
class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("सभी मेंबर्स"), backgroundColor: Colors.black),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('menus').orderBy('date', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(doc['name'] ?? 'No Name'),
                subtitle: Text("${doc['village']} | ${doc['phone']}"),
              );
            },
          );
        },
      ),
    );
  }
}
