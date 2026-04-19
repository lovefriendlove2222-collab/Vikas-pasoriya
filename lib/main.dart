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
    print("Firebase Load Error: $e");
  }
  runApp(const VikasFinalApp());
}

class VikasFinalApp extends StatelessWidget {
  const VikasFinalApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.orange),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // थारा रीयलटाइम डेटाबेस लिंक
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/',
  ).ref();

  // यहाँ मैंने "Default" डेटा डाल दिया है ताकि सफेद स्क्रीन ना आए
  String infoMsg = "विकास पासोरिया ऑफिशियिल में आपका स्वागत है";
  String upiVal = "vikas@upi";
  String videoId = "4wrWluZisiw"; 
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _setupPlayer();
    _listenData();
  }

  void _setupPlayer() {
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  void _listenData() {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          infoMsg = data["purnima"] ?? "कोई नई सूचना नहीं है।";
          upiVal = data["upi"] ?? "vikas@upi";
          String newUrl = data["videoId"] ?? "";
          String? newId = YoutubePlayer.convertUrlToId(newUrl);
          if (newId != null && newId != videoId) {
            videoId = newId;
            _controller?.load(videoId);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vikas Pasoriya Official"),
        backgroundColor: Colors.orange[900],
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.admin_panel_settings), onPressed: () => _adminAuth())],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            YoutubePlayer(controller: _controller!, showVideoProgressIndicator: true),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(children: [
                _card("🌕 कार्यक्रम सूचना", infoMsg),
                const SizedBox(height: 20),
                _btn("💰 दान करें", Colors.green[800]!, Icons.qr_code, () => _pay()),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(String t, String c) => Card(
    child: Container(
      width: double.infinity, padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(border: Border.all(color: Colors.orange), borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 18)),
        const Divider(),
        Text(c, style: const TextStyle(fontSize: 16)),
      ]),
    ),
  );

  Widget _btn(String t, Color c, IconData i, VoidCallback tap) => ElevatedButton.icon(
    icon: Icon(i, color: Colors.white), label: Text(t, style: const TextStyle(color: Colors.white)),
    style: ElevatedButton.styleFrom(backgroundColor: c, minimumSize: const Size(double.infinity, 55)),
    onPressed: tap,
  );

  void _pay() {
    showModalBottomSheet(context: context, builder: (c) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        QrImageView(data: "upi://pay?pa=$upiVal&pn=Vikas&cu=INR", size: 200),
        const Text("स्कैन करें और सहयोग करें")
      ]),
    ));
  }

  void _adminAuth() {
    final pass = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("एडमिन लॉगिन"),
      content: TextField(controller: pass, decoration: const InputDecoration(labelText: "पासवर्ड"), obscureText: true),
      actions: [ElevatedButton(onPressed: () {
        if(pass.text == "Vikas1998") { // थारा जन्म साल
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminPage()));
        }
      }, child: const Text("लॉगिन"))],
    ));
  }
}

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});
  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/').ref();
    final v = TextEditingController(), p = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text("Control Panel")),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        TextField(controller: v, decoration: const InputDecoration(labelText: "YouTube Link")),
        ElevatedButton(onPressed: () => ref.update({"videoId": v.text}), child: const Text("Update Video")),
        const SizedBox(height: 20),
        TextField(controller: p, decoration: const InputDecoration(labelText: "Info Text")),
        ElevatedButton(onPressed: () => ref.update({"purnima": p.text}), child: const Text("Update Info")),
      ])),
    );
  }
}
