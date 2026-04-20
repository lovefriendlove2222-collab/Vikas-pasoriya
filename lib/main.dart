import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const VikasOfficial());
}

class VikasOfficial extends StatelessWidget {
  const VikasOfficial({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.orange),
      home: const LiveScreen(),
    );
  }
}

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});
  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  final DatabaseReference _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/',
  ).ref();

  String upi = "7206966924vivek@axl";
  String videoId = "4wrWluZisiw";
  YoutubePlayerController? _ytController;
  List<Map<String, String>> dynamicData = [];

  @override
  void initState() {
    super.initState();
    _ytController = YoutubePlayerController(initialVideoId: videoId, flags: const YoutubePlayerFlags(autoPlay: false));
    _listenLive();
  }

  void _listenLive() {
    // यो परमानेंट सिंक सै—फायरबेस बदलैगा तो ऐप अपने आप बदल जावेगा
    _db.onValue.listen((event) {
      final dynamic raw = event.snapshot.value;
      if (raw != null && raw is Map) {
        setState(() {
          upi = raw["upi"]?.toString() ?? upi;
          String? nId = YoutubePlayer.convertUrlToId(raw["videoId"]?.toString() ?? "");
          if (nId != null && nId != videoId) {
            videoId = nId;
            _ytController?.load(videoId);
          }
          dynamicData.clear();
          if (raw["options"] is Map) {
            (raw["options"] as Map).forEach((k, v) => dynamicData.add({"t": k.toString(), "d": v.toString()}));
          } else if (raw["purnima"] != null) {
            dynamicData.add({"t": "अगला प्रोग्राम", "d": raw["purnima"].toString()});
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
          YoutubePlayer(controller: _ytController!),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(children: [
              ...dynamicData.map((e) => Card(child: ListTile(title: Text(e["t"]!), subtitle: Text(e["d"]!)))),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _pay(),
                icon: const Icon(Icons.qr_code),
                label: const Text("सहयोग करें", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 60)),
              )
            ]),
          ),
        ]),
      ),
    );
  }

  void _pay() {
    showModalBottomSheet(context: context, builder: (c) => Center(child: QrImageView(data: "upi://pay?pa=$upi&pn=Vikas", size: 250)));
  }
}
