import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MaterialApp(home: VikasBadshahApp(), debugShowCheckedModeBanner: false));

class VikasBadshahApp extends StatefulWidget {
  const VikasBadshahApp({super.key});
  @override
  State<VikasBadshahApp> createState() => _VikasState();
}

class _VikasState extends State<VikasBadshahApp> {
  // 3. वीडियो लिंक्स (एडमिन यहाँ हजारों लिंक डाल सकेगा)
  final List<String> videoIds = ['7n9O7p25lYg', 'dQw4w9WgXcQ']; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("vikas pasoriya"), // 1. बिना डेश के नाम
        backgroundColor: Colors.orange,
        actions: [
          // 11, 14. राइट मेनू: एडमिन लॉगिन और डेवलपर सम्पर्क
          PopupMenuButton(itemBuilder: (context) => [
            const PopupMenuItem(child: Text("एडमिन लॉगिन (पॉसवर्ड)")),
            PopupMenuItem(child: const Text("डेवलपर: विवेक कौशिक \n+91 7206966924"),
              onTap: () => launchUrl(Uri.parse("tel:+917206966924"))),
          ]),
        ],
      ),

      // 8, 9, 10. लेफ्ट मेनू (Drawer)
      drawer: Drawer(
        child: ListView(
          children: [
            // 2. लोगो यहाँ दिखेगा
            const DrawerHeader(child: Icon(Icons.person, size: 80, color: Colors.orange)),
            _menuTile("संस्था की पूरी जानकारी", Icons.info), // 9
            _menuTile("पूर्णमासी कार्यक्रम", Icons.event), // 8
            _menuTile("रेगुलर कार्यक्रम", Icons.calendar_today), // 8
            _menuTile("कार्यक्रम बुकिंग", Icons.phone), // 10
            _menuTile("गुरु जी की पाठशाला टीम", Icons.group), // 10
          ],
        ),
      ),

      body: Column(
        children: [
          // 4, 5. डोनर पट्टी (Scrolling Marquee)
          Container(height: 35, color: Colors.red, child: const Center(
            child: Text("नवीनतम डोनर: अमित (बाढड़ा) - ₹1100 ... संस्था: गुरु जी की पाठशाला", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),

          // 3, 5. वीडियो डैशबोर्ड (Mute/Unmute के साथ)
          Expanded(child: ListView.builder(itemCount: videoIds.length, itemBuilder: (context, i) {
            return Padding(padding: const EdgeInsets.all(8.0), child: YoutubePlayer(
              controller: YoutubePlayerController(initialVideoId: videoIds[i], 
              flags: const YoutubePlayerFlags(mute: true, autoPlay: false))));
          })),

          // 4, 6. डोनेशन और मंथली डोनर बटन
          Container(padding: const EdgeInsets.all(12), color: Colors.grey[200], child: Row(children: [
            _btn("डोनेशन", Colors.green), const SizedBox(width: 10), _btn("मंथली डोनर", Colors.blue),
          ])),
        ],
      ),
    );
  }
  Widget _menuTile(String t, IconData i) => ListTile(leading: Icon(i, color: Colors.orange), title: Text(t));
  Widget _btn(String l, Color c) => Expanded(child: ElevatedButton(onPressed: () {}, 
    style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white), child: Text(l)));
}
