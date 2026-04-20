import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: VikasLive(), debugShowCheckedModeBanner: false));
}

class VikasLive extends StatefulWidget {
  const VikasLive({super.key});
  @override
  State<VikasLive> createState() => _VikasLiveState();
}

class _VikasLiveState extends State<VikasLive> {
  final _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/',
  ).ref();

  String upi = "7206966924vivek@axl";
  String vId = "4wrWluZisiw";
  YoutubePlayerController? _cont;
  List<Map<String, String>> options = [];

  @override
  void initState() {
    super.initState();
    _cont = YoutubePlayerController(initialVideoId: vId, flags: const YoutubePlayerFlags(autoPlay: false));
    _db.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          upi = data["upi"]?.toString() ?? upi;
          String? nId = YoutubePlayer.convertUrlToId(data["videoId"]?.toString() ?? "");
          if (nId != null && nId != vId) { _cont?.load(nId); vId = nId; }
          options.clear();
          if (data["options"] is Map) {
            (data["options"] as Map).forEach((k, v) => options.add({"t": k.toString(), "d": v.toString()}));
          } else {
            options.add({"t": "सूचना", "d": data["purnima"]?.toString() ?? "राम राम भाई"});
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vikas Pasoriya Official"), backgroundColor: Colors.orange[800]),
      body: SingleChildScrollView(child: Column(children: [
        YoutubePlayer(controller: _cont!),
        ...options.map((e) => Card(child: ListTile(title: Text(e["t"]!), subtitle: Text(e["d"]!)))),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () => showModalBottomSheet(context: context, builder: (c) => Center(child: QrImageView(data: "upi://pay?pa=$upi&pn=Vikas", size: 250))), child: const Text("सहयोग करें")),
      ])),
    );
  }
}
