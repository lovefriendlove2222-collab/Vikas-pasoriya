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
  runApp(const VikasFinalApp());
}

class VikasFinalApp extends StatelessWidget {
  const VikasFinalApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vikas Pasoriya',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.orange),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // थारा रीयलटाइम डेटाबेस लिंक
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/',
  ).ref();

  String purnimaMsg = "डेटा लोड हो रहा है...";
  String upiId = "7206966924vivek@axl";
  String videoId = "4wrWluZisiw"; // Default Video
  YoutubePlayerController? _ytController;

  @override
  void initState() {
    super.initState();
    _ytController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
    _listenToFirebase();
  }

  void _listenToFirebase() {
    _dbRef.onValue.listen((event) {
      final Map? data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          purnimaMsg = data["purnima"] ?? "सूचना जल्द आएगी।";
          upiId = data["upi"] ?? "7206966924vivek@axl";
          String? newId = YoutubePlayer.convertUrlToId(data["videoId"] ?? "");
          if (newId != null && newId != videoId) {
            videoId = newId;
            _ytController?.load(videoId);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("विकास पासोरिया ऑफिशियिल", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange[900],
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.lock_open), onPressed: () => _openAdmin())],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // १. यूट्यूब प्लेयर
            YoutubePlayer(
              controller: _ytController!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.orange,
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [
                // २. सूचना कार्ड
                Card(
                  elevation: 4,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text("🌕 कार्यक्रम सूचना", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                      const Divider(),
                      Text(purnimaMsg, style: const TextStyle(fontSize: 16)),
                    ]),
                  ),
                ),
                
                const SizedBox(height: 25),
                
                // ३. पेमेंट बटन
                ElevatedButton.icon(
                  onPressed: () => _showQR(),
                  icon: const Icon(Icons.qr_code, color: Colors.white),
                  label: const Text("सहयोग करें (QR कोड)", style: TextStyle(color: Colors.white, fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void _showQR() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => Container(
        padding: const EdgeInsets.all(30),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("स्कैन करके सहयोग करें", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          QrImageView(data: "upi://pay?pa=$upiId&pn=Vikas&cu=INR", size: 200),
          const SizedBox(height: 10),
          Text("UPI ID: $upiId"),
        ]),
      ),
    );
  }

  void _openAdmin() {
    final passController = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("एडमिन लॉगिन"),
      content: TextField(controller: passController, decoration: const InputDecoration(labelText: "पासवर्ड"), obscureText: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("बंद करें")),
        ElevatedButton(onPressed: () {
          if (passController.text == "Vikas1998") { // थारा जन्म साल
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminPanel()));
          }
        }, child: const Text("लॉगिन")),
      ],
    ));
  }
}

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/').ref();
    final vCon = TextEditingController();
    final pCon = TextEditingController();
    final uCon = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("कंट्रोल पैनल")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          TextField(controller: vCon, decoration: const InputDecoration(labelText: "नया यूट्यूब वीडियो लिंक")),
          ElevatedButton(onPressed: () => ref.update({"videoId": vCon.text}), child: const Text("वीडियो बदलें")),
          const Divider(height: 40),
          TextField(controller: pCon, decoration: const InputDecoration(labelText: "नई सूचना")),
          ElevatedButton(onPressed: () => ref.update({"purnima": pCon.text}), child: const Text("सूचना अपडेट करें")),
          const Divider(height: 40),
          TextField(controller: uCon, decoration: const InputDecoration(labelText: "नया UPI ID")),
          ElevatedButton(onPressed: () => ref.update({"upi": uCon.text}), child: const Text("UPI सेव करें")),
        ]),
      ),
    );
  }
}
