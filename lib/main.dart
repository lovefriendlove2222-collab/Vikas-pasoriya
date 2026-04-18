import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 5));
  } catch (e) {
    print("Firebase Error: $e");
  }
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
        scaffoldBackgroundColor: const Color(0xFFFFF8E1),
        textTheme: GoogleFonts.hindTextTheme(),
      ),
      // ऐप खुलते ही होम स्क्रीन आएगी
      home: const HomeScreen(),
    );
  }
}

// ---------------- 1. होम स्क्रीन (image_10.png वाली) ----------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('विकास पासोरिया ऑफिसियल'),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              // एडमिन पेज पर ले जाने वाला बटन
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLoginPage()));
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fort_rounded, size: 120, color: Colors.deepOrange),
            const SizedBox(height: 20),
            const Text('हरि ॐ जी!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              icon: const Icon(Icons.volunteer_activism, color: Colors.white),
              label: const Text('सहयोग राशि / डोनेशन दें', style: TextStyle(color: Colors.white, fontSize: 18)),
              onPressed: () {
                // डोनेशन पेज पर ले जाने वाला बटन
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DonationPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- 2. डोनेशन पेज (नया फॉर्म) ----------------
class DonationPage extends StatefulWidget {
  const DonationPage({super.key});
  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _village = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _amount = TextEditingController();
  bool _loading = false;

  _saveAndDonate() async {
    if (_name.text.isEmpty || _mobile.text.isEmpty || _amount.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया पूरी जानकारी भरें!')));
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('donations').add({
        'name': _name.text,
        'mobile': _mobile.text,
        'village': _village.text,
        'city': _city.text,
        'state': _state.text,
        'amount': _amount.text,
        'time': DateTime.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('विवरण सुरक्षित सेव हो गया!')));
      Navigator.pop(context);
    } catch (e) {
      print(e);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('डोनेशन विवरण')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'आपका नाम *')),
            TextField(controller: _mobile, decoration: const InputDecoration(labelText: 'मोबाइल नम्बर *'), keyboardType: TextInputType.phone),
            TextField(controller: _village, decoration: const InputDecoration(labelText: 'गाँव')),
            TextField(controller: _city, decoration: const InputDecoration(labelText: 'शहर')),
            TextField(controller: _state, decoration: const InputDecoration(labelText: 'राज्य')),
            TextField(controller: _amount, decoration: const InputDecoration(labelText: 'सहयोग राशि (₹) *'), keyboardType: TextInputType.number),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _saveAndDonate, child: const Text('सेव करें और आगे बढ़ें')),
          ],
        ),
      ),
    );
  }
}

// ---------------- 3. एडमिन लॉगिन और लिस्ट ----------------
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});
  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _pass = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('एडमिन लॉगिन')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          TextField(controller: _pass, decoration: const InputDecoration(labelText: 'पासवर्ड दर्ज करें'), obscureText: true),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () {
            if (_pass.text == "vikas@bhagwa") {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('गलत पासवर्ड!')));
            }
          }, child: const Text('लॉगिन करें'))
        ]),
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('डोनेशन डेटा लिस्ट')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('donations').orderBy('time', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, i) {
              var d = snap.data!.docs[i];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text("${d['name']} - ₹${d['amount']}"),
                  subtitle: Text("${d['mobile']}\n${d['village']}, ${d['city']}"),
                  trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => d.reference.delete()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
