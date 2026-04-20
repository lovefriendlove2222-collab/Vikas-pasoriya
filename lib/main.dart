import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: VikasOfficialApp(), debugShowCheckedModeBanner: false));
}

class VikasOfficialApp extends StatefulWidget {
  const VikasOfficialApp({super.key});
  @override
  State<VikasOfficialApp> createState() => _VikasOfficialAppState();
}

class _VikasOfficialAppState extends State<VikasOfficialApp> {
  final _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/',
  ).ref();

  String upi = "7206966924vivek@axl";
  String vId = "4wrWluZisiw";
  YoutubePlayerController? _yt;
  List<Map<String, String>> uiData = [];

  @override
  void initState() {
    super.initState();
    _yt = YoutubePlayerController(initialVideoId: vId, flags: const YoutubePlayerFlags(autoPlay: false));
    _db.onValue.listen((event) {
      final snap = event.snapshot.value as Map?;
      if (snap != null) {
        setState(() {
          upi = snap["upi"]?.toString() ?? upi;
          String? nId = YoutubePlayer.convertUrlToId(snap["videoId"]?.toString() ?? "");
          if (nId != null && nId != vId) { vId = nId; _yt?.load(vId); }
          uiData.clear();
          if (snap["options"] is Map) {
            (snap["options"] as Map).forEach((k, v) => uiData.add({"t": k.toString(), "d": v.toString()}));
          } else {
            uiData.add({"t": "सूचना", "d": snap["purnima"]?.toString() ?? "राम राम!"});
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vikas Pasoriya Official"), backgroundColor: Colors.orange),
      body: SingleChildScrollView(child: Column(children: [
        YoutubePlayer(controller: _yt!),
        ...uiData.map((e) => Card(child: ListTile(title: Text(e["t"]!), subtitle: Text(e["d"]!)))),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => showModalBottomSheet(context: context, builder: (c) => Center(child: QrImageView(data: "upi://pay?pa=$upi&pn=Vikas", size: 250))),
          child: const Text("सहयोग करें"),
        )
      ])),
    );
  }
}
