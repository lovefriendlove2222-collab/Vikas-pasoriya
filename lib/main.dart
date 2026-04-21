import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MaterialApp(home: VikasApp(), debugShowCheckedModeBanner: false));

class VikasApp extends StatefulWidget {
  const VikasApp({super.key});
  @override
  State<VikasApp> createState() => _VikasAppState();
}

class _VikasAppState extends State<VikasApp> {
  // 3. वीडियो लिंक्स (यहाँ जितने चाहो उतने लिंक डालो)
  final List<String> videoIds = ['7n9O7p25lYg', 'dQw4w9WgXcQ'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("vikas pasoriya"), // 1. बिना डेश के नाम
        backgroundColor: Colors.orange,
        actions: [
          PopupMenuButton(itemBuilder: (context) => [
            const PopupMenuItem(child: Text("11. एडमिन लॉगिन")),
            PopupMenuItem(child: const Text("14. डेवलपर: विवेक कौशिक (+91 7206966924)"), 
              onTap: () => launchUrl(Uri.parse("tel:+917206966924"))),
          ]),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Image.asset('assets/logo.jpg', errorBuilder: (c,e,s) => const Icon(Icons.person, size: 80))),
            _tile("9. संस्था जानकारी", Icons.info),
            _tile("8. कार्यक्रम कैलेंडर", Icons.event),
            _tile("10. बुकिंग सम्पर्क", Icons.phone),
          ],
        ),
      ),
      body: Column(
        children: [
          // 4, 5. डोनर पट्टी (Marquee)
          Container(height: 35, color: Colors.red, child: const Center(child: Text("धन्यवाद डोनर: अमित (बाढड़ा) - ₹1100", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          // 3. वीडियो डैशबोर्ड
          Expanded(child: ListView.builder(itemCount: videoIds.length, itemBuilder: (context, i) => Padding(padding: const EdgeInsets.all(8), 
            child: YoutubePlayer(controller: YoutubePlayerController(initialVideoId: videoIds[i], flags: const YoutubePlayerFlags(mute: true, autoPlay: false)))))),
          // 4. डोनेशन बटन
          Padding(padding: const EdgeInsets.all(10), child: Row(children: [
            _btn("डोनेशन", Colors.green), const SizedBox(width: 10), _btn("मंथली डोनर", Colors.blue),
          ])),
        ],
      ),
    );
  }
  Widget _tile(String t, IconData i) => ListTile(leading: Icon(i, color: Colors.orange), title: Text(t));
  Widget _btn(String l, Color c) => Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white), child: Text(l)));
}
