import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: VikasFinalApp(), debugShowCheckedModeBanner: false));
}

class VikasFinalApp extends StatefulWidget {
  const VikasFinalApp({super.key});
  @override
  State<VikasFinalApp> createState() => _VikasFinalAppState();
}

class _VikasFinalAppState extends State<VikasFinalApp> {
  final _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/',
  ).ref();

  String upi = "7206966924vivek@axl";
  String vId = "4wrWluZisiw";
  YoutubePlayerController? _ytCont;
  List<Map<String, String>> uiOptions = [];

  @override
  void initState() {
    super.initState();
    _ytCont = YoutubePlayerController(initialVideoId: vId, flags: const YoutubePlayerFlags(autoPlay: false));
    
    // लाइव ऑनलाइन सिंक - परमानेंट
    _db.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          upi = data["upi"]?.toString() ?? upi;
          String? extractedId = YoutubePlayer.convertUrlToId(data["videoId"]?.toString() ?? "");
          if (extractedId != null && extractedId != vId) {
            vId = extractedId;
            _ytCont?.load(vId);
          }
          uiOptions.clear();
          if (data["options"] is Map) {
            (data["options"] as Map).forEach((k, v) => uiOptions.add({"t": k.toString(), "d": v.toString()}));
          } else {
            uiOptions.add({"t": "सूचना", "d": data["purnima"]?.toString() ?? "राम राम भाई!"});
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("विकास पासोरिया ऑफिशियिल"), backgroundColor: Colors.orange[800]),
      body: SingleChildScrollView(
        child: Column(children: [
          YoutubePlayer(controller: _ytCont!, showVideoProgressIndicator: true),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(children: [
              ...uiOptions.map((e) => Card(child: ListTile(title: Text(e["t"]!), subtitle: Text(e["d"]!)))),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _payNow(),
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

  void _payNow() {
    showModalBottomSheet(context: context, builder: (c) => Center(
      child: QrImageView(data: "upi://pay?pa=$upi&pn=Vikas", size: 250),
    ));
  }
}
