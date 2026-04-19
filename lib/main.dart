import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // फायरबेस चालू
  runApp(const VikasAppV2());
}

class VikasAppV2 extends StatelessWidget {
  const VikasAppV2({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFFFFBF2),
      ),
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
  // तेरा रियलटाइम लिंक यहाँ सैट है भाई
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
    _connectCloud();
  }

  // क्लाउड से डेटा अपने आप अपडेट होगा
  _connectCloud() {
    _db.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          purnima = data["purnima"] ?? "जल्द अपडेट होगा";
          upi = data["upi"] ?? "example@upi";
          String newVId = YoutubePlayer.convertUrlToId(data["videoId"] ?? "") ?? "";
          
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
        title: const Text("विकास पासोरिया (LIVE)"),
        backgroundColor: Colors.orange[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => _showLogin(),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // १. लाइव यूट्यूब वीडियो (ऑटो-प्ले)
            if (vId.isNotEmpty && _ytController != null)
              YoutubePlayer(controller: _ytController!, showVideoProgressIndicator: true)
            else
              Container(height: 220, color: Colors.black, child: const Center(child: Text("लाइव प्रोग्राम लोड हो रहा है...", style: TextStyle(color: Colors.white)))),

            // २. डोनर पट्टी (चलती हुई)
            if (donors.isNotEmpty)
              Container(
                height: 35, 
                color: Colors.orange[100],
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: donors.length,
                  itemBuilder: (c, i) => Center(child: Text(" ✨ ${donors[i]['name']} (${donors[i]['village']}) | ", style: const TextStyle(fontWeight: FontWeight.bold))),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  _infoBox("🌕 आगामी पूर्णमासी कार्यक्रम", purnima),
                  const SizedBox(height: 20),
                  _largeBtn("💰 दान करें और रशीद पाएँ", Colors.green[800]!, Icons.qr_code, () => _paymentUI()),
                  const SizedBox(height: 25),
                  const Text("🏆 हमारे मुख्य दानदाता", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  ...donors.reversed.take(5).map((d) => ListTile(
                    leading: const Icon(Icons.stars, color: Colors.amber),
                    title: Text(d['name']),
                    subtitle: Text(d['village']),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String t, String c) => Card(
    elevation: 4,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
        const Divider(),
        Text(c, style: const TextStyle(fontSize: 16)),
      ]),
    ),
  );

  Widget _largeBtn(String t, Color c, IconData i, VoidCallback tap) => ElevatedButton.icon(
    icon: Icon(i),
    label: Text(t, style: const TextStyle(fontSize: 16, color: Colors.white)),
    style: ElevatedButton.styleFrom(backgroundColor: c, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    onPressed: tap,
  );

  _paymentUI() {
    showModalBottomSheet(context: context, builder: (c) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("स्कैन करें और पे करें", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        QrImageView(data: "upi://pay?pa=$upi&pn=Vikas&cu=INR", size: 180),
        const SizedBox(height: 15),
        ElevatedButton(onPressed: () { Navigator.pop(context); _getReceiptData(); }, child: const Text("पेमेंट हो गया, रशीद भरें"))
      ]),
    ));
  }

  _getReceiptData() {
    final n = TextEditingController(), v = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("रशीद के लिए जानकारी"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: n, decoration: const InputDecoration(labelText: "आपका नाम")),
        TextField(controller: v, decoration: const InputDecoration(labelText: "गाँव का नाम")),
      ]),
      actions: [ElevatedButton(onPressed: () {
        _db.child("donors").push().set({"name": n.text, "village": v.text, "date": DateTime.now().toString()});
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("रशीद सेव हो गई! धन्यवाद।")));
      }, child: const Text("सेव करें"))],
    ));
  }

  _showLogin() {
    final pass = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("एडमिन लॉगिन"),
      content: TextField(controller: pass, decoration: const InputDecoration(labelText: "पासवर्ड"), obscureText: true),
      actions: [ElevatedButton(onPressed: () {
        if(pass.text == "Vikas1998") { 
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminPanel()));
        }
      }, child: const Text("लॉगिन"))],
    ));
  }
}

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});
  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/').ref();
    final vid = TextEditingController(), pur = TextEditingController(), upiC = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("संस्था कंट्रोल पैनल"), backgroundColor: Colors.red[900], foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          TextField(controller: vid, decoration: const InputDecoration(labelText: "यूट्यूब वीडियो लिंक (Live/New)")),
          ElevatedButton(onPressed: () => ref.update({"videoId": vid.text}), child: const Text("वीडियो बदलें")),
          const SizedBox(height: 20),
          TextField(controller: pur, decoration: const InputDecoration(labelText: "पूर्णमासी कार्यक्रम अपडेट")),
          ElevatedButton(onPressed: () => ref.update({"purnima": pur.text}), child: const Text("सूचना अपडेट करें")),
          const SizedBox(height: 20),
          TextField(controller: upiC, decoration: const InputDecoration(labelText: "नया UPI ID (e.g. name@upi)")),
          ElevatedButton(onPressed: () => ref.update({"upi": upiC.text}), child: const Text("UPI सैट करें")),
        ]),
      ),
    );
  }
}
