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
    debugPrint("फायरबेस लोड नहीं हुआ: $e");
  }
  runApp(const VikasApp());
}

class VikasApp extends StatelessWidget {
  const VikasApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.orange),
      home: const VikasMainScreen(),
    );
  }
}

class VikasMainScreen extends StatefulWidget {
  const VikasMainScreen({super.key});
  @override
  State<VikasMainScreen> createState() => _VikasMainScreenState();
}

class _VikasMainScreenState extends State<VikasMainScreen> {
  // थारा रीयलटाइम डेटाबेस यूआरएल
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/',
  ).ref();

  String purnimaText = "डेटाबेस तै जुड़न लग रहा हूँ..."; 
  String upiId = "7206966924vivek@axl";
  String vId = "4wrWluZisiw";
  YoutubePlayerController? _ytController;

  @override
  void initState() {
    super.initState();
    _initYoutube();
    _startSync();
  }

  void _initYoutube() {
    _ytController = YoutubePlayerController(
      initialVideoId: vId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  void _startSync() {
    _database.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          // डेटाबेस तै "purnima" वाली लाइन उठा रहा सै
          purnimaText = data["purnima"] ?? "कोई सूचना नहीं मिली";
          upiId = data["upi"] ?? "7206966924vivek@axl";
          String? extractedId = YoutubePlayer.convertUrlToId(data["videoId"] ?? "");
          if (extractedId != null && extractedId != vId) {
            vId = extractedId;
            _ytController?.load(vId);
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
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          if (_ytController != null)
            YoutubePlayer(controller: _ytController!, showVideoProgressIndicator: true),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Card(
                elevation: 4,
                child: ListTile(
                  title: const Text("🌕 अगला प्रोग्राम", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  subtitle: Text(purnimaText, style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => _showPayment(),
                icon: const Icon(Icons.qr_code, color: Colors.white),
                label: const Text("सहयोग करें", style: TextStyle(color: Colors.white, fontSize: 18)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], minimumSize: const Size(double.infinity, 60)),
              )
            ]),
          ),
        ]),
      ),
    );
  }

  void _showPayment() {
    showModalBottomSheet(context: context, builder: (c) => Container(
      padding: const EdgeInsets.all(30),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("QR कोड स्कैन करें", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        QrImageView(data: "upi://pay?pa=$upiId&pn=Vikas&cu=INR", size: 200),
      ]),
    ));
  }
}
