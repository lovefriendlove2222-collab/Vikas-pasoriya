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
    debugPrint("Firebase Initialize Error: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.orange),
      home: const VikasHome(),
    );
  }
}

class VikasHome extends StatefulWidget {
  const VikasHome({super.key});
  @override
  State<VikasHome> createState() => _VikasHomeState();
}

class _VikasHomeState extends State<VikasHome> {
  // थारा डेटाबेस लिंक
  final DatabaseReference _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/',
  ).ref();

  String info = "सूचना लोड हो रही है...";
  String upi = "7206966924vivek@axl"; // थारा डेटाबेस वाला UPI
  String vId = "4wrWluZisiw";
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: vId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
    _listenData();
  }

  void _listenData() {
    _db.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          info = data["purnima"] ?? "सूचना उपलब्ध नहीं है";
          upi = data["upi"] ?? "7206966924vivek@axl";
          String link = data["videoId"] ?? "";
          String? id = YoutubePlayer.convertUrlToId(link);
          if (id != null && id != vId) {
            vId = id;
            _controller?.load(vId);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("विकास पासोरिया", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          YoutubePlayer(controller: _controller!, showVideoProgressIndicator: true),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _infoCard("🌕 कार्यक्रम सूचना", info),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: () => _showPayQR(),
                icon: const Icon(Icons.qr_code, color: Colors.white),
                label: const Text("सहयोग करें (QR कोड)", style: TextStyle(color: Colors.white, fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  minimumSize: const Size(double.infinity, 60),
                ),
              )
            ]),
          )
        ]),
      ),
    );
  }

  Widget _infoCard(String t, String c) => Card(
    elevation: 5,
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
        const Divider(),
        Text(c, style: const TextStyle(fontSize: 16)),
      ]),
    ),
  );

  void _showPayQR() {
    showModalBottomSheet(context: context, builder: (c) => Container(
      padding: const EdgeInsets.all(30),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("स्कैन करके दान करें", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        QrImageView(data: "upi://pay?pa=$upi&pn=Vikas&cu=INR", size: 200),
      ]),
    ));
  }
}
