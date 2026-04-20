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
      home: const VikasLiveScreen(),
    );
  }
}

class VikasLiveScreen extends StatefulWidget {
  const VikasLiveScreen({super.key});
  @override
  State<VikasLiveScreen> createState() => _VikasLiveScreenState();
}

class _VikasLiveScreenState extends State<VikasLiveScreen> {
  final DatabaseReference _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/',
  ).ref();

  String upi = "7206966924vivek@axl";
  String vId = "4wrWluZisiw";
  YoutubePlayerController? _controller;
  List<Map<String, String>> liveList = [];

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(initialVideoId: vId, flags: const YoutubePlayerFlags(autoPlay: false));
    _startSync();
  }

  void _startSync() {
    _db.onValue.listen((event) {
      final dynamic data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          upi = data["upi"]?.toString() ?? upi;
          String? newId = YoutubePlayer.convertUrlToId(data["videoId"]?.toString() ?? "");
          if (newId != null && newId != vId) {
            vId = newId;
            _controller?.load(vId);
          }
          liveList.clear();
          if (data["options"] is Map) {
            (data["options"] as Map).forEach((k, v) => liveList.add({"t": k.toString(), "d": v.toString()}));
          } else {
            liveList.add({"t": "सूचना", "d": data["purnima"]?.toString() ?? "स्वागत है"});
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("विकास पासोरिया ऑफिशियिल"), backgroundColor: Colors.orange),
      body: SingleChildScrollView(
        child: Column(children: [
          YoutubePlayer(controller: _controller!),
          ...liveList.map((e) => Card(child: ListTile(title: Text(e["t"]!), subtitle: Text(e["d"]!)))),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () => _pay(), child: const Text("सहयोग करें")),
        ]),
      ),
    );
  }

  void _pay() {
    showModalBottomSheet(context: context, builder: (c) => Center(child: QrImageView(data: "upi://pay?pa=$upi&pn=Vikas", size: 250)));
  }
}
