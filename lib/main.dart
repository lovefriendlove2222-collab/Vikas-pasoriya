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
  runApp(const VikasOfficialApp());
}

class VikasOfficialApp extends StatelessWidget {
  const VikasOfficialApp({super.key});
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

  String upi = "7206966924vivek@axl";
  String vId = "4wrWluZisiw";
  YoutubePlayerController? _controller;
  List<Map<String, String>> adminOptions = [];

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: vId,
      flags: const YoutubePlayerFlags(autoPlay: false),
    );
    _listenData();
  }

  void _listenData() {
    _dbRef.onValue.listen((event) {
      // फोटो 1000338888.jpg वाला एरर यहाँ फिक्स करा है
      final Object? dataValue = event.snapshot.value;
      
      if (dataValue != null && dataValue is Map) {
        setState(() {
          upi = dataValue["upi"]?.toString() ?? upi;
          
          // यूट्यूब वीडियो अपडेट
          String? newId = YoutubePlayer.convertUrlToId(dataValue["videoId"]?.toString() ?? "");
          if (newId != null && newId != vId) {
            vId = newId;
            _controller?.load(vId);
          }

          // एडमिन ऑप्शन लिस्ट (Map एरर फिक्स के साथ)
          adminOptions.clear();
          if (dataValue["options"] != null && dataValue["options"] is Map) {
            final Map<dynamic, dynamic> optionsMap = dataValue["options"] as Map;
            optionsMap.forEach((key, value) {
              adminOptions.add({
                "title": key.toString(),
                "desc": value.toString()
              });
            });
          } else if (dataValue["purnima"] != null) {
            // अगर पुराना सिस्टम ही रखना हो
            adminOptions.add({
              "title": "अगला प्रोग्राम",
              "desc": dataValue["purnima"].toString()
            });
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
            padding: const EdgeInsets.all(15),
            child: Column(children: [
              // एडमिन पैनल तै आए नए ऑप्शन यहाँ दिखेंगे
              ...adminOptions.map((opt) => Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.info, color: Colors.orange),
                  title: Text(opt["title"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(opt["desc"]!),
                ),
              )),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _showPayQR(),
                icon: const Icon(Icons.qr_code, color: Colors.white),
                label: const Text("सहयोग करें", style: TextStyle(color: Colors.white, fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  minimumSize: const Size(double.infinity, 60)
                ),
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
