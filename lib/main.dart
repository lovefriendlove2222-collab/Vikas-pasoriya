import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const VikasApp());
}

class VikasApp extends StatelessWidget {
  const VikasApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  final DatabaseReference _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/',
  ).ref();

  String upi = "7206966924vivek@axl";
  String vId = "4wrWluZisiw";
  YoutubePlayerController? _controller;
  List<Map<String, String>> liveData = [];

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: vId,
      flags: const YoutubePlayerFlags(autoPlay: false),
    );
    _syncNow();
  }

  void _syncNow() {
    _db.onValue.listen((event) {
      final dynamic rawData = event.snapshot.value;
      if (rawData != null && rawData is Map) {
        setState(() {
          upi = rawData["upi"]?.toString() ?? upi;
          String? newId = YoutubePlayer.convertUrlToId(rawData["videoId"]?.toString() ?? "");
          if (newId != null && newId != vId) {
            vId = newId;
            _controller?.load(vId);
          }
          liveData.clear();
          if (rawData["options"] is Map) {
            (rawData["options"] as Map).forEach((k, v) {
              liveData.add({"t": k.toString(), "d": v.toString()});
            });
          } else if (rawData["purnima"] != null) {
            liveData.add({"t": "प्रोग्राम", "d": rawData["purnima"].toString()});
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("विकास पासोरिया ऑफिशियिल"), backgroundColor: Colors.orange[900], foregroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(children: [
          YoutubePlayer(controller: _controller!),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(children: [
              ...liveData.map((item) => Card(child: ListTile(title: Text(item["t"]!), subtitle: Text(item["d"]!)))),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () => _showQR(), child: const Text("सहयोग करें")),
            ]),
          ),
        ]),
      ),
    );
  }

  void _showQR() {
    showModalBottomSheet(context: context, builder: (c) => Center(child: QrImageView(data: "upi://pay?pa=$upi&pn=Vikas", size: 250)));
  }
}
