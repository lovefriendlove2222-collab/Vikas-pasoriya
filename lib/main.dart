import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // १. क्लाउड इंजन चालू
  await Firebase.initializeApp(); 
  runApp(const VikasUltimateApp());
}

class VikasUltimateApp extends StatelessWidget {
  const VikasUltimateApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFFFFBF2),
      ),
      home: const UserDashboard(),
    );
  }
}

// --- २. यूजर डैशबोर्ड (Realtime Sync & Video) ---
class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  // थारा लाइव लिंक यहाँ सैट सै
  final DatabaseReference _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/',
  ).ref();

  String purnima = "लोड हो रहा है...", regular = "चेक कर रहे हैं...", upi = "example@upi", vId = "";
  List donors = [], monthlyDonors = [];
  YoutubePlayerController? _ytController;

  @override
  void initState() {
    super.initState();
    _startCloudSync();
  }

  // ३. क्लाउड तै सीधा कनैक्शन
  _startCloudSync() {
    _db.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          purnima = data["purnima"] ?? "अपडेट जल्द आएगा";
          regular = data["regular"] ?? "कोई प्रोग्राम नहीं";
          upi = data["upi"] ?? "example@upi";
          String newVId = data["videoId"] ?? "";
          
          // वीडियो आईडी बदलते ही प्लेयर अपने आप बदलेगा
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
          if (data["monthly"] != null) {
            monthlyDonors = Map.from(data["monthly"]).values.toList();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminLogin())),
          )
        ],
      ),
      body: Column(
        children: [
          // लाइव यूट्यूब वीडियो सेक्शन
          if (vId.isNotEmpty && _ytController != null)
            YoutubePlayer(controller: _ytController!, showVideoProgressIndicator: true)
          else
            Container(height: 200, color: Colors.black, child: const Center(child: Text("लाइव वीडियो लोड हो रही है...", style: TextStyle(color: Colors.white)))),

          // डोनर स्क्रॉल पट्टी
          if (donors.isNotEmpty)
            Container(height: 30, color: Colors.orange[100],
              child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: donors.length,
                itemBuilder: (c, i) => Center(child: Text(" ✨ ${donors[i]['name']} (${donors[i]['village']}) | ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)))),
            ),

          Expanded(
            child: ListView(padding: const EdgeInsets.all(15), children: [
              _infoCard("🌕 पूर्णमासी कार्यक्रम", purnima, Colors.orange),
              _infoCard("📅 रेगुलर प्रोग्राम", regular, Colors.blueGrey),
              const SizedBox(height: 10),
              _btn("💰 दान करें (रशीद पाएँ)", Colors.green[800]!, Icons.qr_code, () => _paymentUI(false)),
              _btn("🗓️ मंथली डोनर सदस्य बनें", Colors.blue[900]!, Icons.calendar_month, () => _paymentUI(true)),
              const Padding(padding: EdgeInsets.all(15), child: Text("🏆 हमारे मंथली डोनर्स", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ...monthlyDonors.map((m) => ListTile(leading: const Icon(Icons.stars, color: Colors.amber), title: Text(m['name']), subtitle: Text(m['village']))),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String t, String c, Color col) => Card(margin: const EdgeInsets.only(bottom: 10), elevation: 3, child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: col)), const Divider(), Text(c)])));
  
  Widget _btn(String t, Color c, IconData i, VoidCallback tap) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: ElevatedButton.icon(icon: Icon(i), label: Text(t), style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55)), onPressed: tap));

  // --- ४. पेमेंट और रशीद सिस्टम ---
  _paymentUI(bool isMonthly) {
    showModalBottomSheet(context: context, builder: (c) => Container(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text("स्कैन करें या पे करें", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      QrImageView(data: "upi://pay?pa=$upi&pn=Vikas&cu=INR", size: 160),
      const SizedBox(height: 15),
      ElevatedButton(onPressed: () { Navigator.pop(context); _askDonorData(isMonthly); }, child: const Text("पेमेंट हो गया, रशीद भरें"))
    ])));
  }

  _askDonorData(bool isM) {
    final n = TextEditingController(), v = TextEditingController(), m = TextEditingController();
    showDialog(context: context, barrierDismissible: false, builder: (c) => AlertDialog(
      title: Text(isM ? "मंथली डोनर जानकारी" : "दानदाता जानकारी"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: n, decoration: const InputDecoration(labelText: "आपका नाम")),
        TextField(controller: v, decoration: const InputDecoration(labelText: "गाँव")),
        TextField(controller: m, decoration: const InputDecoration(labelText: "मोबाइल नंबर")),
      ]),
      actions: [ElevatedButton(onPressed: () => _saveToCloud(n.text, v.text, m.text, isM), child: const Text("डिजिटल रशीद पाएँ"))],
    ));
  }

  _saveToCloud(String name, String village, String phone, bool isM) async {
    Map<String, String> d = {"name": name, "village": village, "phone": phone, "date": DateTime.now().toString().split(' ')[0]};
    String path = isM ? "monthly" : "donors";
    await _db.child(path).push().set(d);
    Navigator.pop(context);
    _showFinalReceipt(d);
  }

  _showFinalReceipt(Map d) => showDialog(context: context, builder: (c) => AlertDialog(
    content: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(border: Border.all(color: Colors.orange, width: 2), borderRadius: BorderRadius.circular(10)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("विकास पासोरिया संस्था", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Divider(),
        Text("डोनर: ${d['name']}"), Text("गाँव: ${d['village']}"),
        const SizedBox(height: 10), const Text("🙏 आपका धन्यवाद 🙏"),
      ])),
  ));
}

// --- ५. एडमिन पैनल (दुनिया भर के ऐप यहाँ से बदलें) ---
class AdminLogin extends StatelessWidget {
  const AdminLogin({super.key});
  @override
  Widget build(BuildContext context) {
    final pc = TextEditingController();
    return Scaffold(body: Center(child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text("प्रशासक लॉगिन", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      TextField(controller: pc, decoration: const InputDecoration(labelText: "पासवर्ड", border: OutlineInputBorder()), obscureText: true),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: () { if(pc.text == "Vikas1998") Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const AdminDash())); }, child: const Text("प्रवेश करें"))
    ]))));
  }
}

class AdminDash extends StatelessWidget {
  const AdminDash({super.key});
  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/').ref();
    return Scaffold(
      appBar: AppBar(title: const Text("क्लाउड कंट्रोल सेंटर"), backgroundColor: Colors.red[900]),
      body: ListView(padding: const EdgeInsets.all(15), children: [
        _adminEdit(ref, "वीडियो ID (e.g. dQw4w9WgXcQ)", "videoId"),
        _adminEdit(ref, "पूर्णमासी अपडेट", "purnima"),
        _adminEdit(ref, "रेगुलर प्रोग्राम", "regular"),
        _adminEdit(ref, "UPI ID सैट करें", "upi"),
        const Divider(height: 40),
        const Text("डेटाबेस लाइव सिंक है। यहाँ जो बदलोगे वो सबके फोन में बदल जाएगा।", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
      ]),
    );
  }

  Widget _adminEdit(DatabaseReference ref, String label, String key) {
    final con = TextEditingController();
    return Padding(padding: const EdgeInsets.only(bottom: 15), child: Column(children: [
      TextField(controller: con, maxLines: key == "purnima" || key == "regular" ? 3 : 1, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())),
      const SizedBox(height: 5),
      ElevatedButton(onPressed: () async {
        await ref.update({key: con.text});
        con.clear();
      }, child: Text("$label अपडेट करें"))
    ]));
  }
}
