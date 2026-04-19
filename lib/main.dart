import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // यहाँ Firebase Initialize होगा (अगर कॉन्फ़िगरेशन फाइल है)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase Note: Config missing, using local backup.");
  }
  runApp(const VikasUltimateApp());
}

class VikasUltimateApp extends StatelessWidget {
  const VikasUltimateApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange, scaffoldBackgroundColor: const Color(0xFFFFFBF2)),
      home: const UserDashboard(),
    );
  }
}

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  // डेटाबेस रेफरेंस (Realtime Database)
  final _db = FirebaseDatabase.instance.ref();
  
  Map data = {
    "purnima": "अपडेट लोड हो रहा है...",
    "regular": "चेक कर रहे हैं...",
    "upi": "example@upi",
    "ytLinks": "",
    "donors": []
  };

  @override
  void initState() {
    super.initState();
    _listenToUpdates(); // ऑनलाइन सिंक चालू
  }

  // --- १. ऑनलाइन सिंक लॉजिक (Realtime Sync) ---
  _listenToUpdates() {
    _db.onValue.listen((event) {
      final snapshot = event.snapshot.value as Map?;
      if (snapshot != null) {
        setState(() {
          data["purnima"] = snapshot["purnima"] ?? "जल्द आ रहा है";
          data["regular"] = snapshot["regular"] ?? "कोई प्रोग्राम नहीं";
          data["upi"] = snapshot["upi"] ?? "example@upi";
          data["ytLinks"] = snapshot["ytLinks"] ?? "";
          data["donors"] = snapshot["donors"] != null ? Map.from(snapshot["donors"]).values.toList() : [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> links = data["ytLinks"].toString().split(',').where((s) => s.isNotEmpty).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("विकास पासोरिया (Online Sync)"),
        backgroundColor: Colors.orange[900],
        actions: [
          IconButton(icon: const Icon(Icons.admin_panel_settings), 
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminLogin())))
        ],
      ),
      body: Column(
        children: [
          // लाइव हेडलाइन
          if(links.isNotEmpty) Container(height: 40, color: Colors.red[900],
            child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: links.length,
              itemBuilder: (c, i) => Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15), 
              child: Text("🔥 LIVE: वीडियो ${i+1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))))),

          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [
                _card("🌕 पूर्णमासी अपडेट", data["purnima"], Colors.orange),
                _card("📅 रेगुलर प्रोग्राम", data["regular"], Colors.blueGrey),
                const SizedBox(height: 10),
                _btn("💰 दान करें (UPI/QR)", Colors.green[800]!, Icons.qr_code, () => _showPayment(data["upi"])),
                const Padding(padding: EdgeInsets.all(15), child: Text("🏆 हालिया डोनर्स", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                ...data["donors"].reversed.take(5).map((d) => ListTile(title: Text(d['name']), subtitle: Text(d['village']))),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(String t, String c, Color col) => Card(margin: const EdgeInsets.all(10), child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: TextStyle(fontWeight: FontWeight.bold, color: col)), const Divider(), Text(c)])));
  
  Widget _btn(String t, Color c, IconData i, VoidCallback tap) => Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: ElevatedButton.icon(icon: Icon(i), label: Text(t), style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55)), onPressed: tap));

  _showPayment(String upi) {
    showModalBottomSheet(context: context, builder: (c) => Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 20), QrImageView(data: "upi://pay?pa=$upi&pn=Vikas", size: 180),
      ElevatedButton(onPressed: () => _askDetails(), child: const Text("पेमेंट कर दिया (रशीद भरें)"))
    ]));
  }

  _askDetails() {
    final n = TextEditingController(), v = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("रशीद के लिए जानकारी"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: n, decoration: const InputDecoration(labelText: "नाम")), TextField(controller: v, decoration: const InputDecoration(labelText: "गाँव"))]),
      actions: [ElevatedButton(onPressed: () {
        _db.child("donors").push().set({"name": n.text, "village": v.text, "date": DateTime.now().toString()});
        Navigator.pop(context);
        Navigator.pop(context);
      }, child: const Text("रशीद पाएँ"))],
    ));
  }
}

// --- २. एडमिन पैनल (Online Update) ---
class AdminLogin extends StatelessWidget {
  const AdminLogin({super.key});
  @override
  Widget build(BuildContext context) {
    final pc = TextEditingController();
    return Scaffold(body: Center(child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: pc, decoration: const InputDecoration(labelText: "Master Password"), obscureText: true),
      ElevatedButton(onPressed: () { if(pc.text == "Vikas1998") Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const AdminDash())); }, child: const Text("Login"))
    ]))));
  }
}

class AdminDash extends StatelessWidget {
  const AdminDash({super.key});
  final _db = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cloud Control"), backgroundColor: Colors.red[900]),
      body: ListView(padding: const EdgeInsets.all(15), children: [
        _editField("पूर्णमासी अपडेट", "purnima"),
        _editField("रेगुलर प्रोग्राम", "regular"),
        _editField("यूट्यूब लिंक (Comma ,)", "ytLinks"),
        _editField("UPI ID", "upi"),
      ]),
    );
  }

  Widget _editField(String label, String key) {
    final con = TextEditingController();
    return Padding(padding: const EdgeInsets.only(bottom: 20), child: Column(children: [
      TextField(controller: con, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())),
      ElevatedButton(onPressed: () => _db.update({key: con.text}), child: Text("$label अपडेट करें"))
    ]));
  }
}
