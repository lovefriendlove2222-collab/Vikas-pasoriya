import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const VikasPasoriyaOfficial());
}

class VikasPasoriyaOfficial extends StatelessWidget {
  const VikasPasoriyaOfficial({super.key});
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
  final DatabaseReference _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/',
  ).ref();

  String upiId = "7206966924vivek@axl";
  String videoId = "4wrWluZisiw";
  YoutubePlayerController? _ytController;
  
  // नए ऑप्शन के लिए लिस्ट
  List<Map<String, dynamic>> extraOptions = [];

  @override
  void initState() {
    super.initState();
    _ytController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: false),
    );
    _listenToData();
  }

  void _listenToData() {
    _db.onValue.listen((event) {
      final dynamic data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          upiId = data["upi"]?.toString() ?? upiId;
          
          // यूट्यूब वीडियो अपडेट
          String? newId = YoutubePlayer.convertUrlToId(data["videoId"]?.toString() ?? "");
          if (newId != null && newId != videoId) {
            videoId = newId;
            _ytController?.load(videoId);
          }

          // एडमिन पैनल तै 'options' नाम की लिस्ट पढ़ना
          if (data["options"] != null && data["options"] is Map) {
            extraOptions.clear();
            (data["options"] as Map).forEach((key, value) {
              extraOptions.add({"title": key, "desc": value});
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
          YoutubePlayer(controller: _ytController!, showVideoProgressIndicator: true),
          
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(children: [
              // ये हैं वो नए ऑप्शन जो तू डेटाबेस तै जोड़ेगा
              ...extraOptions.map((opt) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.star, color: Colors.orange),
                  title: Text(opt["title"], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(opt["desc"]),
                ),
              )).toList(),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _showQR(),
                icon: const Icon(Icons.payment, color: Colors.white),
                label: const Text("सहयोग करें (QR)", style: TextStyle(color: Colors.white, fontSize: 18)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], minimumSize: const Size(double.infinity, 60)),
              ),
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
        const Text("QR कोड स्कैन करें", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        QrImageView(data: "upi://pay?pa=$upiId&pn=Vikas&cu=INR", size: 200),
      ]),
    ));
  }
}
