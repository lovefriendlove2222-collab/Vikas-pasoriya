import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("फायरबेस लोड नहीं हुआ: $e");
  }
  runApp(const VikasAppV3());
}

class VikasAppV3 extends StatelessWidget {
  const VikasAppV3({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.orange),
      home: const VikasDashboard(),
    );
  }
}

class VikasDashboard extends StatefulWidget {
  const VikasDashboard({super.key});
  @override
  State<VikasDashboard> createState() => _VikasDashboardState();
}

class _VikasDashboardState extends State<VikasDashboard> {
  // थारा डेटाबेस लिंक
  final DatabaseReference _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/',
  ).ref();

  String purnima = "लोड हो रहा है...", upi = "example@upi", vId = "";
  YoutubePlayerController? _ytController;

  @override
  void initState() {
    super.initState();
    _startLiveSync();
  }

  _startLiveSync() {
    _db.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          purnima = data["purnima"] ?? "अपडेट जल्द आएगा।";
          upi = data["upi"] ?? "example@upi";
          String rawUrl = data["videoId"] ?? "";
          String? extractedId = YoutubePlayer.convertUrlToId(rawUrl);
          
          if (extractedId != null && extractedId != vId) {
            vId = extractedId;
            _ytController = YoutubePlayerController(
              initialVideoId: vId,
              flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("विकास पासोरिया ऑफिशियिल"),
        backgroundColor: Colors.orange[900],
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.admin_panel_settings), onPressed: () => _loginDialog())],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // १. लाइव वीडियो प्लेयर
            if (_ytController != null)
              YoutubePlayer(controller: _ytController!, showVideoProgressIndicator: true)
            else
              Container(height: 220, color: Colors.black, child: const Center(child: Text("लाइव प्रोग्राम लोड हो रहा है...", style: TextStyle(color: Colors.white)))),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _infoCard("🌕 पूर्णमासी कार्यक्रम", purnima),
                const SizedBox(height: 20),
                _bigBtn("💰 दान करें (रशीद पाएँ)", Colors.green[800]!, Icons.qr_code, () => _showQR()),
                const SizedBox(height: 10),
                _bigBtn("📅 मंथली डोनर सदस्य", Colors.blue[900]!, Icons.star, () => _showQR()),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // यहाँ Container का एरर ठीक कर दिया है
  Widget _infoCard(String t, String c) => Card(
    elevation: 3,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withOpacity(0.3)), // Border यहाँ आएगा
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
        const Divider(),
        Text(c, style: const TextStyle(fontSize: 16)),
      ]),
    ),
  );

  Widget _bigBtn(String t, Color c, IconData i, VoidCallback tap) => ElevatedButton.icon(
    icon: Icon(i, color: Colors.white),
    label: Text(t, style: const TextStyle(color: Colors.white, fontSize: 16)),
    style: ElevatedButton.styleFrom(backgroundColor: c, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    onPressed: tap,
  );

  _showQR() {
    showModalBottomSheet(context: context, builder: (c) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("QR कोड स्कैन करें", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        QrImageView(data: "upi://pay?pa=$upi&pn=Vikas&cu=INR", size: 180),
        const SizedBox(height: 10),
        const Text("पेमेंट के बाद रशीद भरना ना भूलें।"),
      ]),
    ));
  }

  _loginDialog() {
    final pc = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("एडमिन लॉगिन"),
      content: TextField(controller: pc, decoration: const InputDecoration(labelText: "पासवर्ड"), obscureText: true),
      actions: [ElevatedButton(onPressed: () {
        if(pc.text == "Vikas1998") { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminDash())); }
      }, child: const Text("लॉगिन"))],
    ));
  }
}

class AdminDash extends StatelessWidget {
  const AdminDash({super.key});
  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/').ref();
    final v = TextEditingController(), p = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text("कंट्रोल पैनल")),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        TextField(controller: v, decoration: const InputDecoration(labelText: "नया यूट्यूब वीडियो लिंक")),
        ElevatedButton(onPressed: () => ref.update({"videoId": v.text}), child: const Text("वीडियो बदलें")),
        const SizedBox(height: 20),
        TextField(controller: p, decoration: const InputDecoration(labelText: "पूर्णमासी कार्यक्रम सूचना")),
        ElevatedButton(onPressed: () => ref.update({"purnima": p.text}), child: const Text("सूचना अपडेट करें")),
      ])),
    );
  }
}
।
