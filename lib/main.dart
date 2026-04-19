import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const VikasPasoriyaApp());
}

class VikasPasoriyaApp extends StatelessWidget {
  const VikasPasoriyaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.orange),
      home: const MainAppScreen(),
    );
  }
}

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});
  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  // थारा परमानेंट डेटाबेस लिंक
  final DatabaseReference _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/',
  ).ref();

  String upi = "7206966924vivek@axl";
  String vId = "4wrWluZisiw";
  YoutubePlayerController? _controller;
  List<Map<String, String>> liveOptions = [];

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: vId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false, isLive: true),
    );
    _setupOnlineSync();
  }

  // यो सै वो परमानेंट ऑनलाइन सिंक का जादू
  void _setupOnlineSync() {
    _db.onValue.listen((event) {
      final Object? data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          upi = data["upi"]?.toString() ?? upi;
          
          // वीडियो सिंक
          String? newId = YoutubePlayer.convertUrlToId(data["videoId"]?.toString() ?? "");
          if (newId != null && newId != vId) {
            vId = newId;
            _controller?.load(vId);
          }

          // एडमिन ऑप्शन सिंक
          liveOptions.clear();
          if (data["options"] != null && data["options"] is Map) {
            (data["options"] as Map).forEach((k, v) {
              liveOptions.add({"title": k.toString(), "desc": v.toString()});
            });
          } else if (data["purnima"] != null) {
            liveOptions.add({"title": "अगला प्रोग्राम", "desc": data["purnima"].toString()});
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
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          YoutubePlayer(controller: _controller!, showVideoProgressIndicator: true),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(children: [
              ...liveOptions.map((item) => Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.info_outline, color: Colors.orange),
                  title: Text(item["title"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item["desc"]!),
                ),
              )),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _showQR(),
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: const Text("सहयोग करें", style: TextStyle(color: Colors.white, fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
              )
            ]),
          ),
        ]),
      ),
    );
  }

  void _showQR() {
    showModalBottomSheet(context: context, builder: (c) => Container(
      padding: const EdgeInsets.all(30),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("स्कैन करके दान करें", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        QrImageView(data: "upi://pay?pa=$upi&pn=Vikas&cu=INR", size: 220),
        const SizedBox(height: 10),
        Text("UPI: $upi"),
      ]),
    ));
  }
}
