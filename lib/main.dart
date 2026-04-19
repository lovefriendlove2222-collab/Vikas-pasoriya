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
  final DatabaseReference _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/',
  ).ref();

  String info = "लोड हो रहा है...";
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
    _listen();
  }

  void _listen() {
    _db.onValue.listen((event) {
      final Map? data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          info = data["purnima"] ?? "सूचना नहीं है";
          upi = data["upi"] ?? "7206966924vivek@axl";
          String? id = YoutubePlayer.convertUrlToId(data["videoId"] ?? "");
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
      appBar: AppBar(title: const Text("Vikas Pasoriya"), backgroundColor: Colors.orange),
      body: SingleChildScrollView(
        child: Column(children: [
          YoutubePlayer(controller: _controller!),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _card("🌕 प्रोग्राम", info),
              const SizedBox(height: 20),
              _btn("💰 सहयोग", () => _showQR()),
            ]),
          )
        ]),
      ),
    );
  }

  Widget _card(String t, String c) => Card(child: ListTile(title: Text(t), subtitle: Text(c)));

  Widget _btn(String t, VoidCallback tap) => ElevatedButton(
    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
    onPressed: tap, child: Text(t),
  );

  void _showQR() {
    showModalBottomSheet(context: context, builder: (c) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        QrImageView(data: "upi://pay?pa=$upi&pn=Vikas&cu=INR", size: 200),
      ]),
    ));
  }
}
