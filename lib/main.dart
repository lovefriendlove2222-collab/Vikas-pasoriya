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
  runApp(const VikasPasoriyaApp());
}

class VikasPasoriyaApp extends StatelessWidget {
  const VikasPasoriyaApp({super.key});
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
  // थारा डेटाबेस यूआरएल
  final DatabaseReference _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/',
  ).ref();

  String purnimaMsg = "सूचना लोड हो रही है...";
  String upiId = "7206966924vivek@axl";
  String videoId = "4wrWluZisiw";
  YoutubePlayerController? _ytController;

  @override
  void initState() {
    super.initState();
    _ytController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: false),
    );
    _syncWithDatabase();
  }

  void _syncWithDatabase() {
    _db.onValue.listen((event) {
      // फोटो 1000338888.jpg वाला Map एरर यहाँ फिक्स करा है
      final dynamic rawData = event.snapshot.value;
      if (rawData != null && rawData is Map) {
        setState(() {
          purnimaMsg = rawData["purnima"]?.toString() ?? "कोई सूचना नहीं";
          upiId = rawData["upi"]?.toString() ?? "7206966924vivek@axl";
          String? newId = YoutubePlayer.convertUrlToId(rawData["videoId"]?.toString() ?? "");
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
        title: const Text("विकास पासोरिया ऑफिशियिल"),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          YoutubePlayer(controller: _ytController!, showVideoProgressIndicator: true),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Card(
                elevation: 4,
                child: ListTile(
                  title: const Text("🌕 अगला प्रोग्राम", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  subtitle: Text(purnimaMsg, style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => _payNow(),
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

  void _payNow() {
    showModalBottomSheet(context: context, builder: (c) => Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("QR कोड स्कैन करें", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        QrImageView(data: "upi://pay?pa=$upiId&pn=Vikas&cu=INR", size: 250),
      ]),
    ));
  }
}
