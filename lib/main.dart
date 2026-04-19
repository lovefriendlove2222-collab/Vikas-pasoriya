import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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

  String purnima = "लोड हो रहा है...";
  String upi = "7206966924vivek@axl";
  String videoId = "4wrWluZisiw";
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: false),
    );
    _startListening();
  }

  void _startListening() {
    _db.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          purnima = data["purnima"] ?? "कोई सूचना नहीं";
          upi = data["upi"] ?? "7206966924vivek@axl";
          String? newId = YoutubePlayer.convertUrlToId(data["videoId"] ?? "");
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
      appBar: AppBar(title: const Text("विकास पासोरिया ऑफिशियिल"), backgroundColor: Colors.orange),
      body: Column(children: [
        YoutubePlayer(controller: _controller!),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            child: ListTile(
              title: const Text("🌕 अगला प्रोग्राम", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(purnima),
            ),
          ),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => _showQR(),
          icon: const Icon(Icons.qr_code),
          label: const Text("सहयोग करें"),
          style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
        ),
        const SizedBox(height: 50),
      ]),
    );
  }

  void _showQR() {
    showModalBottomSheet(context: context, builder: (c) => Center(
      child: QrImageView(data: "upi://pay?pa=$upi&pn=Vikas", size: 250),
    ));
  }
}
