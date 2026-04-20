import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: VikasRealApp(), debugShowCheckedModeBanner: false));
}

class VikasRealApp extends StatefulWidget {
  const VikasRealApp({super.key});
  @override
  State<VikasRealApp> createState() => _VikasRealAppState();
}

class _VikasRealAppState extends State<VikasRealApp> {
  final _db = FirebaseDatabase.instance.ref();
  String upi = "7206966924vivek@axl";
  String vId = "4wrWluZisiw";
  YoutubePlayerController? _cont;
  List<Map<String, String>> liveUpdates = [];

  @override
  void initState() {
    super.initState();
    _cont = YoutubePlayerController(initialVideoId: vId, flags: const YoutubePlayerFlags(autoPlay: false));
    
    // ऑनलाइन सिंक: डेटाबेस में बदलाव होते ही ऐप में अपने आप बदलेगा
    _db.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          upi = data["upi"]?.toString() ?? upi;
          String? newId = YoutubePlayer.convertUrlToId(data["videoId"]?.toString() ?? "");
          if (newId != null && newId != vId) {
            vId = newId;
            _cont?.load(vId);
          }
          liveUpdates.clear();
          if (data["options"] is Map) {
            (data["options"] as Map).forEach((k, v) => liveUpdates.add({"t": k.toString(), "d": v.toString()}));
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
        YoutubePlayer(controller: _cont!, showVideoProgressIndicator: true),
        const Padding(padding: EdgeInsets.all(8), child: Text("लाइव प्रोग्राम की जानकारी", style: TextStyle(fontWeight: FontWeight.bold))),
        ...liveUpdates.map((e) => Card(child: ListTile(title: Text(e["t"]!), subtitle: Text(e["d"]!)))),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.payment),
          label: const Text("सहयोग राशि भेजें"),
          onPressed: () => showModalBottomSheet(context: context, builder: (c) => Center(child: QrImageView(data: "upi://pay?pa=$upi&pn=Vikas", size: 250))),
        )
      ])),
    );
  }
}
