import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ऑनलाइन इंजन स्टार्ट
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
  // थारा डेटाबेस लिंक यहाँ जमा फिक्स कर दिया सै
  final DatabaseReference _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/',
  ).ref();

  String purnima = "लोड हो रहा है...", upi = "example@upi", vId = "";
  List donors = [];
  YoutubePlayerController? _ytController;

  @override
  void initState() {
    super.initState();
    _startCloudSync();
  }

  // क्लाउड तै डेटा खैंचना
  _startCloudSync() {
    _db.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          purnima = data["purnima"] ?? "जल्द अपडेट होगा";
          upi = data["upi"] ?? "example@upi";
          String newVId = data["videoId"] ?? "";
          
          if (newVId != vId && newVId.isNotEmpty) {
            vId = newVId;
            _ytController = YoutubePlayerController(
              initialVideoId: vId,
              flags: const YoutubePlayerFlags(autoPlay: true, mute: false, loop: true),
            );
          }

          if (data["donors"] != null) {
            donors = Map.from(data["donors"]).values.toList();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("विकास पासोरिया संस्था"),
        backgroundColor: Colors.orange[900],
        actions: [IconButton(icon: const Icon(Icons.security), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminLogin())))],
      ),
      body: Column(
        children: [
          // ऑटो-प्ले वीडियो सेक्शन
          if (vId.isNotEmpty && _ytController != null)
            YoutubePlayer(controller: _ytController!, showVideoProgressIndicator: true)
          else
            Container(height: 200, color: Colors.black, child: const Center(child: Text("लाइव वीडियो लोड हो रही है...", style: TextStyle(color: Colors.white)))),

          // डोनर पट्टी
          if (donors.isNotEmpty)
            Container(height: 30, color: Colors.orange[100],
              child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: donors.length,
                itemBuilder: (c, i) => Center(child: Text(" ✨ ${donors[i]['name']} | ", style: const TextStyle(fontWeight: FontWeight.bold)))),
            ),

          Expanded(
            child: ListView(padding: const EdgeInsets.all(15), children: [
              _card("🌕 पूर्णमासी कार्यक्रम", purnima, Colors.orange),
              const SizedBox(height: 10),
              _btn("💰 दान करें (रशीद पाएँ)", Colors.green[800]!, Icons.qr_code, () => _paymentDialog()),
              const Padding(padding: EdgeInsets.all(15), child: Text("🏆 डोनर्स सूची", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ...donors.reversed.take(5).map((d) => ListTile(title: Text(d['name']), subtitle: Text(d['village']))),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _card(String t, String c, Color col) => Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: TextStyle(fontWeight: FontWeight.bold, color: col)), const Divider(), Text(c)])));
  
  Widget _btn(String t, Color c, IconData i, VoidCallback tap) => ElevatedButton.icon(icon: Icon(i), label: Text(t), style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55)), onPressed: tap);

  _paymentDialog() {
    showModalBottomSheet(context: context, builder: (c) => Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 20), QrImageView(data: "upi://pay?pa=$upi&pn=Vikas&cu=INR", size: 160),
      ElevatedButton(onPressed: () { Navigator.pop(context); _askDetails(); }, child: const Text("पेमेंट हो गया, रशीद भरें"))
    ]));
  }

  _askDetails() {
    final n = TextEditingController(), v = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("जानकारी भरें"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: n, decoration: const InputDecoration(labelText: "नाम")), TextField(controller: v, decoration: const InputDecoration(labelText: "गाँव"))]),
      actions: [ElevatedButton(onPressed: () {
        _db.child("donors").push().set({"name": n.text, "village": v.text, "date": DateTime.now().toString()});
        Navigator.pop(context);
      }, child: const Text("सेव करें"))],
    ));
  }
}

// --- एडमिन एरिया ---
class AdminLogin extends StatelessWidget {
  const AdminLogin({super.key});
  @override
  Widget build(BuildContext context) {
    final pc = TextEditingController();
    return Scaffold(body: Center(child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: pc, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
      ElevatedButton(onPressed: () { if(pc.text == "Vikas1998") Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const AdminDash())); }, child: const Text("Login"))
    ]))));
  }
}

class AdminDash extends StatelessWidget {
  const AdminDash({super.key});
  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/').ref();
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Control"), backgroundColor: Colors.red[900]),
      body: ListView(padding: const EdgeInsets.all(15), children: [
        _editField(ref, "यूट्यूब वीडियो ID", "videoId"),
        _editField(ref, "पूर्णमासी अपडेट", "purnima"),
        _editField(ref, "UPI ID", "upi"),
      ]),
    );
  }

  Widget _editField(DatabaseReference ref, String label, String key) {
    final con = TextEditingController();
    return Padding(padding: const EdgeInsets.only(bottom: 15), child: Column(children: [
      TextField(controller: con, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())),
      ElevatedButton(onPressed: () => ref.update({key: con.text}), child: Text("लाइव अपडेट करें"))
    ]));
  }
}
