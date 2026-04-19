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
  runApp(const VikasApp());
}

class VikasApp extends StatelessWidget {
  const VikasApp({super.key});
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

  String info = "डेटा लोड हो रहा है...";
  String upi = "7206966924vivek@axl";
  String vId = "4wrWluZisiw";
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: vId,
      flags: const YoutubePlayerFlags(autoPlay: false),
    );
    _listenToData();
  }

  void _listenToData() {
    _dbRef.onValue.listen((event) {
      // फोटो 1000338888.jpg वाला एरर यहाँ फिक्स करा है
      final Object? dataValue = event.snapshot.value;
      
      if (dataValue != null && dataValue is Map) {
        setState(() {
          info = dataValue["purnima"]?.toString() ?? "कोई सूचना नहीं";
          upi = dataValue["upi"]?.toString() ?? "7206966924vivek@axl";
          String? newId = YoutubePlayer.convertUrlToId(dataValue["videoId"]?.toString() ?? "");
          if (newId != null && newId != vId) {
            vId = newId;
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
        title: const Text("विकास पासोरिया ऑफिशियिल"),
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
                elevation: 5,
                child: ListTile(
                  title: const Text("🌕 अगला प्रोग्राम", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  subtitle: Text(info, style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => _showPayQR(),
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

  void _showPayQR() {
    showModalBottomSheet(context: context, builder: (c) => Container(
      padding: const EdgeInsets.all(30),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("QR कोड स्कैन करें", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        QrImageView(data: "upi://pay?pa=$upi&pn=Vikas&cu=INR", size: 200),
      ]),
    ));
  }
}
