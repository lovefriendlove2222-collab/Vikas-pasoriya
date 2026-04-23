import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MaterialApp(
  title: "vikas pasoriya",
  home: VikasPasoriyaHome(),
  debugShowCheckedModeBanner: false,
));

class VikasPasoriyaHome extends StatefulWidget {
  const VikasPasoriyaHome({super.key});
  @override
  State<VikasPasoriyaHome> createState() => _VikasHomeState();
}

class _VikasHomeState extends State<VikasPasoriyaHome> {
  // 3. वीडियो लिंक्स (यूट्यूब/फेसबुक लिंक यहाँ डलेंगे)
  final List<String> vids = ['7n9O7p25lYg', 'dQw4w9WgXcQ']; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("vikas pasoriya"), // 1. बिना डेश के
        backgroundColor: Colors.orange,
        actions: [
          // 11. एडमिन और 14. डेवलपर सम्पर्क
          PopupMenuButton(itemBuilder: (context) => [
            const PopupMenuItem(child: Text("एडमिन लॉगिन")),
            PopupMenuItem(child: const Text("डेवलपर: विवेक कौशिक (+91 7206966924)"),
              onTap: () => launchUrl(Uri.parse("tel:+917206966924"))),
          ]),
        ],
      ),
      
      // 8, 9, 10. लेफ्ट मेनू (Drawer)
      drawer: Drawer(
        child: ListView(
          children: [
            // 2. लोगो
            const DrawerHeader(child: Icon(Icons.person, size: 80, color: Colors.orange)),
            _tile("9. संस्था की जानकारी", Icons.info),
            _tile("8. कार्यक्रम कैलेंडर", Icons.event),
            _tile("10. कार्यक्रम बुकिंग", Icons.phone),
            _tile("10. पाठशाला टीम", Icons.group),
          ],
        ),
      ),

      body: Column(
        children: [
          // 4, 5. डोनर पट्टी (Marquee)
          Container(height: 35, color: Colors.red, child: const Center(
            child: Text("नवीनतम डोनर: अमित (बाढड़ा) - ₹1100 ... संस्था: गुरु जी की पाठशाला", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),

          // 3, 5. वीडियो डैशबोर्ड (Mute/Unmute)
          Expanded(child: ListView.builder(itemCount: vids.length, itemBuilder: (context, i) {
            return Padding(padding: const EdgeInsets.all(8.0), child: YoutubePlayer(
              controller: YoutubePlayerController(initialVideoId: vids[i], 
              flags: const YoutubePlayerFlags(mute: true, autoPlay: false))));
          })),

          // 4, 6. डोनेशन और मंथली डोनर बटन
          Container(padding: const EdgeInsets.all(12), color: Colors.grey[100], child: Row(children: [
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
