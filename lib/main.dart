import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const VikasAppFinal());
}

class VikasAppFinal extends StatelessWidget {
  const VikasAppFinal({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.orange),
      home: const MainDashboard(),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});
  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  // थारा रीयलटाइम डेटाबेस लिंक यहाँ फिक्स सै
  final DatabaseReference _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/',
  ).ref();

  String purnima = "लोड हो रहा है...", upi = "example@upi", vId = "";
  YoutubePlayerController? _ytController;

  @override
  void initState() {
    super.initState();
    _startSync();
  }

  _startSync() {
    _db.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          purnima = data["purnima"] ?? "अपडेट जल्द आएगा";
          upi = data["upi"] ?? "example@upi";
          String rawId = data["videoId"] ?? "";
          String? newVId = YoutubePlayer.convertUrlToId(rawId);
          
          if (newVId != null && newVId != vId) {
            vId = newVId;
            _ytController = YoutubePlayerController(
              initialVideoId: vId,
              flags: const YoutubePlayerFlags(autoPlay: true, mute: false, loop: true),
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
        title: const Text("विकास पासोरिया संस्था"),
        backgroundColor: Colors.orange[900],
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.lock_person), onPressed: () => _adminAuth())],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // वीडियो प्लेयर सेक्शन
            if (_ytController != null)
              YoutubePlayer(controller: _ytController!, showVideoProgressIndicator: true)
            else
              Container(height: 220, color: Colors.black, child: const Center(child: Text("लाइव वीडियो लोड हो रही है...", style: TextStyle(color: Colors.white)))),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _buildCard("🌕 पूर्णमासी कार्यक्रम", purnima),
                const SizedBox(height: 20),
                _bigButton("💰 दान करें (रशीद पाएँ)", Colors.green[800]!, Icons.qr_code, () => _showPay()),
                const SizedBox(height: 10),
                _bigButton("🗓️ मंथली डोनर बनें", Colors.blue[900]!, Icons.calendar_month, () => _showPay()),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String content) => Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
        const Divider(),
        Text(content, style: const TextStyle(fontSize: 16)),
      ]),
    ),
  );

  Widget _bigButton(String t, Color c, IconData i, VoidCallback tap) => ElevatedButton.icon(
    icon: Icon(i, color: Colors.white),
    label: Text(t, style: const TextStyle(color: Colors.white, fontSize: 16)),
    style: ElevatedButton.styleFrom(backgroundColor: c, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    onPressed: tap,
  );

  _showPay() {
    showModalBottomSheet(context: context, builder: (c) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        QrImageView(data: "upi://pay?pa=$upi&pn=Vikas&cu=INR", size: 180),
        const Text("स्कैन करें और पेमेंट करें"),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("बंद करें"))
      ]),
    ));
  }

  _adminAuth() {
    final pass = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("एडमिन लॉगिन"),
      content: TextField(controller: pass, decoration: const InputDecoration(labelText: "पासवर्ड"), obscureText: true),
      actions: [ElevatedButton(onPressed: () {
        if(pass.text == "Vikas1998") { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminPanel())); }
      }, child: const Text("लॉगिन"))],
    ));
  }
}

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});
  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/').ref();
    final v = TextEditingController(), p = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text("कंट्रोल पैनल")),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        TextField(controller: v, decoration: const InputDecoration(labelText: "नया यूट्यूब लिंक")),
        ElevatedButton(onPressed: () => ref.update({"videoId": v.text}), child: const Text("वीडियो अपडेट करें")),
        const SizedBox(height: 20),
        TextField(controller: p, decoration: const InputDecoration(labelText: "सूचना अपडेट")),
        ElevatedButton(onPressed: () => ref.update({"purnima": p.text}), child: const Text("सूचना बदलें")),
      ])),
    );
  }
}
