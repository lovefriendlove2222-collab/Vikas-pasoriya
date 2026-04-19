import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // फायरबेस शुरू करना
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("फायरबेस लोड एरर: $e");
  }
  runApp(const VikasPasoriyaApp());
}

class VikasPasoriyaApp extends StatelessWidget {
  const VikasPasoriyaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vikas Pasoriya Official',
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
  // थारा डेटाबेस यूआरएल
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/',
  ).ref();

  String infoText = "डेटा लोड हो रहा है...";
  String upiAddress = "7206966924vivek@axl";
  String currentVideoId = "4wrWluZisiw";
  YoutubePlayerController? _ytController;

  @override
  void initState() {
    super.initState();
    // यूट्यूब प्लेयर सैट करना
    _ytController = YoutubePlayerController(
      initialVideoId: currentVideoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
    _listenToDatabase();
  }

  void _listenToDatabase() {
    // डेटाबेस तै डेटा पढ़ना
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          // डेटाबेस तै "purnima" उठाना
          infoText = data["purnima"] ?? "कोई सूचना नहीं";
          upiAddress = data["upi"] ?? "7206966924vivek@axl";
          
          String? newId = YoutubePlayer.convertUrlToId(data["videoId"] ?? "");
          if (newId != null && newId != currentVideoId) {
            currentVideoId = newId;
            _ytController?.load(currentVideoId);
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
          // वीडियो सेक्शन
          YoutubePlayer(
            controller: _ytController!,
            showVideoProgressIndicator: true,
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              // सूचना कार्ड
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("🌕 कार्यक्रम सूचना", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 18)),
                    const Divider(),
                    Text(infoText, style: const TextStyle(fontSize: 16)),
                  ]),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // पेमेंट बटन
              ElevatedButton.icon(
                onPressed: () => _openQR(),
                icon: const Icon(Icons.qr_code, color: Colors.white),
                label: const Text("सहयोग करें (QR)", style: TextStyle(color: Colors.white, fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  minimumSize: const Size(double.infinity, 60),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  void _openQR() {
    showModalBottomSheet(context: context, builder: (c) => Container(
      padding: const EdgeInsets.all(30),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("स्कैन करें और दान करें", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        QrImageView(data: "upi://pay?pa=$upiAddress&pn=Vikas&cu=INR", size: 220),
      ]),
    ));
  }
}
