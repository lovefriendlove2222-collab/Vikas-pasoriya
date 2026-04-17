import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Firebase शुरू करने की कोशिश
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
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomePage(),
    );
  }
}

// --- 1. मुख्य स्क्रीन (होम पेज) ---
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
          gradient: LinearGradient(
            colors: [Colors.orange[100]!, Colors.white],
            begin: Alignment.topCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("🚩 जय श्री राम 🚩", 
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 10),
            const Text("लोकगायक विकास पासोरिया", 
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
            const SizedBox(height: 50),
            
            // मेंबर रजिस्ट्रेशन बटन
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistrationPage())),
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text("मेंबर रजिस्ट्रेशन", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // एडमिन लॉगिन पॉप-अप
  void _adminLogin(BuildContext context) {
    TextEditingController pass = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("एडमिन लॉगिन"),
        content: TextField(
          controller: pass, 
          decoration: const InputDecoration(hintText: "पासवर्ड यहाँ लिखें"), 
          obscureText: true
        ),
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

  void _saveData() async {
    if (_name.text.isEmpty || _phone.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("कृपया नाम और नंबर भरें!")));
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('menus').add({
        'name': _name.text,
        'phone': _phone.text,
        'village': _village.text,
        'date': DateTime.now().toString(),
      });
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("सफल!"),
            content: const Text("आपकी जानकारी सेव हो गई है।"),
            actions: [TextButton(onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            }, child: const Text("ठीक है"))],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("कनेक्शन एरर: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("मेंबर रजिस्ट्रेशन")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: "आपका नाम", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _village, decoration: const InputDecoration(labelText: "गाँव का नाम", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "मोबाइल नंबर", border: OutlineInputBorder())),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _saveData, 
              child: const Text("डाटा सबमिट करें", style: TextStyle(color: Colors.white, fontSize: 18))
            ),
          ],
        ),
      ),
    );
  }
}

// --- 3. एडमिन पैनल (डेटा देखने के लिए) ---
class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("सभी मेंबर्स की लिस्ट"), backgroundColor: Colors.black),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('menus').orderBy('date', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("अभी कोई मेंबर नहीं है।"));
          
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(doc['name'] ?? 'No Name'),
                  subtitle: Text("गाँव: ${doc['village']} | मो: ${doc['phone']}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
