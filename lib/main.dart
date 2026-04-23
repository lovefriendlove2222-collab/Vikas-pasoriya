import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MaterialApp(
  home: VikasHome(),
  debugShowCheckedModeBanner: false,
));

class VikasHome extends StatefulWidget {
  const VikasHome({super.key});
  @override
  State<VikasHome> createState() => _VikasHomeState();
}

class _VikasHomeState extends State<VikasHome> {
  // 3. वीडियो लिंक्स (यूट्यूब/फेसबुक)
  final List<String> vids = ['7n9O7p25lYg', 'dQw4w9WgXcQ']; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("vikas pasoriya"), // 1. बिना डेश के
        backgroundColor: Colors.orange,
        actions: [
          PopupMenuButton(itemBuilder: (context) => [
            const PopupMenuItem(child: Text("एडमिन लॉगिन")),
            PopupMenuItem(child: const Text("डेवलपर: विवेक कौशिक \n+91 7206966924"),
              onTap: () => launchUrl(Uri.parse("tel:+917206966924"))), // 14
          ]),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Icon(Icons.person, size: 80, color: Colors.orange)),
            _tile("संस्था जानकारी", Icons.info), // 9
            _tile("पूर्णमासी कार्यक्रम", Icons.event), // 8
            _tile("कार्यक्रम बुकिंग", Icons.phone), // 10
          ],
        ),
      ),
      body: Column(
        children: [
          // 4, 5. डोनर पट्टी
          Container(height: 35, color: Colors.red, child: const Center(
            child: Text("नवीनतम डोनर: अमित (बाढड़ा) - ₹1100 ... संस्था: गुरु जी की पाठशाला", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          // 3. वीडियो डैशबोर्ड
          Expanded(child: ListView.builder(itemCount: vids.length, itemBuilder: (context, i) {
            return Padding(padding: const EdgeInsets.all(8.0), child: YoutubePlayer(
              controller: YoutubePlayerController(initialVideoId: vids[i], 
              flags: const YoutubePlayerFlags(mute: true, autoPlay: false))));
          })),
          // 4, 6. डोनेशन बटन
          Padding(padding: const EdgeInsets.all(10), child: Row(children: [
            _btn("डोनेशन", Colors.green), const SizedBox(width: 10), _btn("मंथली डोनर", Colors.blue),
          ])),
        ],
      ),
    );
  }
  Widget _tile(String t, IconData i) => ListTile(leading: Icon(i, color: Colors.orange), title: Text(t));
  Widget _btn(String l, Color c) => Expanded(child: ElevatedButton(onPressed: () {}, 
    style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white), child: Text(l)));
}
