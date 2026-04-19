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
  final _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/',
  ).ref();

  String info = "सूचना लोड हो रही है...";
  String upi = "";
  String vId = "4wrWluZisiw";
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _listen();
  }

  void _initPlayer() {
    _controller = YoutubePlayerController(
      initialVideoId: vId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  void _listen() {
    _db.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          info = data["purnima"] ?? "कोई सूचना नहीं";
          upi = data["upi"] ?? "";
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
        title: const Text("Vikas Pasoriya Official"),
        backgroundColor: Colors.orange[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          YoutubePlayer(controller: _controller!, showVideoProgressIndicator: true),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Card(
                child: ListTile(
                  title: const Text("🌕 कार्यक्रम", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(info),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _showQR(),
                icon: const Icon(Icons.qr_code),
                label: const Text("सहयोग करें"),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              )
            ]),
          )
        ]),
      ),
    );
  }

  void _showQR() {
    showModalBottomSheet(context: context, builder: (c) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        QrImageView(data: "upi://pay?pa=$upi&pn=Vikas&cu=INR", size: 200),
        const Text("स्कैन करें")
      ]),
    ));
  }
}
