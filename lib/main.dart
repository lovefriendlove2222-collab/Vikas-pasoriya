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
    debugPrint("Firebase Error: $e");
  }
  runApp(const VikasAppFinal());
}

class VikasAppFinal extends StatelessWidget {
  const VikasAppFinal({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.orange),
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
  // डेटाबेस लिंक यहाँ फिक्स सै
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/',
  ).ref();

  String purnimaMsg = "अपडेट जल्द आएगा।";
  String upiId = "example@upi";
  String currentVId = "";
  YoutubePlayerController? _ytController;

  @override
  void initState() {
    super.initState();
    _listenToData();
  }

  void _listenToData() {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          purnimaMsg = data["purnima"] ?? "अपडेट जल्द आएगा।";
          upiId = data["upi"] ?? "example@upi";
          final String rawUrl = data["videoId"] ?? "";
          final String? extracted = YoutubePlayer.convertUrlToId(rawUrl);
          
          if (extracted != null && extracted != currentVId) {
            currentVId = extracted;
            _ytController = YoutubePlayerController(
              initialVideoId: currentVId,
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
        actions: [IconButton(icon: const Icon(Icons.settings), onPressed: () => _showLogin())],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_ytController != null)
              YoutubePlayer(controller: _ytController!, showVideoProgressIndicator: true)
            else
              Container(height: 220, color: Colors.black, child: const Center(child: Text("वीडियो लोड हो रही है...", style: TextStyle(color: Colors.white)))),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [
                _infoSection("🌕 पूर्णमासी कार्यक्रम", purnimaMsg),
                const SizedBox(height: 20),
                _actionButton("💰 डोनेशन (रशीद पाएँ)", Colors.green[800]!, Icons.qr_code, () => _openQR()),
                const SizedBox(height: 10),
                _actionButton("⭐ मंथली सदस्य बनें", Colors.blue[900]!, Icons.star, () => _openQR()),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoSection(String title, String desc) => Card(
    elevation: 3,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
        const Divider(),
        Text(desc, style: const TextStyle(fontSize: 16)),
      ]),
    ),
  );

  Widget _actionButton(String txt, Color col, IconData ico, VoidCallback tap) => ElevatedButton.icon(
    icon: Icon(ico, color: Colors.white),
    label: Text(txt, style: const TextStyle(color: Colors.white, fontSize: 16)),
    style: ElevatedButton.styleFrom(backgroundColor: col, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    onPressed: tap,
  );

  void _openQR() {
    showModalBottomSheet(context: context, builder: (c) => Container(
      padding: const EdgeInsets.all(25),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("QR कोड स्कैन करें", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        QrImageView(data: "upi://pay?pa=$upiId&pn=Vikas&cu=INR", size: 180),
        const SizedBox(height: 10),
        const Text("डिजिटल रशीद के लिए संपर्क करें।"),
      ]),
    ));
  }

  void _showLogin() {
    final TextEditingController passCon = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("एडमिन लॉगिन"),
      content: TextField(controller: passCon, decoration: const InputDecoration(labelText: "पासवर्ड"), obscureText: true),
      actions: [ElevatedButton(onPressed: () {
        if(passCon.text == "Vikas1998") { 
          Navigator.pop(context); 
          Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminScreen())); 
        }
      }, child: const Text("लॉगिन"))],
    ));
  }
}

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final DatabaseReference adminRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(), 
      databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/'
    ).ref();
    final TextEditingController vCon = TextEditingController();
    final TextEditingController pCon = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("फुल कंट्रोल पैनल")),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        TextField(controller: vCon, decoration: const InputDecoration(labelText: "नया यूट्यूब लिंक डालें")),
        ElevatedButton(onPressed: () => adminRef.update({"videoId": vCon.text}), child: const Text("वीडियो अपडेट करें")),
        const SizedBox(height: 25),
        TextField(controller: pCon, decoration: const InputDecoration(labelText: "कार्यक्रम सूचना बदलें")),
        ElevatedButton(onPressed: () => adminRef.update({"purnima": pCon.text}), child: const Text("सूचना सेव करें")),
      ])),
    );
  }
}
