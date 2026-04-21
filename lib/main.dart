import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MaterialApp(home: VikasPasoriyaApp(), debugShowCheckedModeBanner: false));

class VikasPasoriyaApp extends StatefulWidget {
  const VikasPasoriyaApp({super.key});
  @override
  State<VikasPasoriyaApp> createState() => _VikasPasoriyaAppState();
}

class _VikasPasoriyaAppState extends State<VikasPasoriyaApp> {
  // 3. वीडियो लिंक्स (एडमिन यहाँ हजारों लिंक डाल सकेगा)
  final List<String> videoIds = ['7n9O7p25lYg', 'dQw4w9WgXcQ']; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. नाम बिना डेश के
      appBar: AppBar(
        title: const Text("vikas pasoriya"), 
        backgroundColor: Colors.orange,
        actions: [
          // 11. राईट मेनू (एडमिन लॉगिन) और 14. डेवलपर सम्पर्क
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text("एडमिन लॉगिन (पॉसवर्ड)")),
              PopupMenuItem(
                child: const Text("डेवलपर: विवेक कौशिक \n+91 7206966924"),
                onTap: () => launchUrl(Uri.parse("tel:+917206966924")),
              ),
            ],
          ),
        ],
      ),

      // 8, 9, 10. लेफ्ट मेनू (Drawer)
      drawer: Drawer(
        child: ListView(
          children: [
            // 2. लोगो यहाँ सैट होगा
            DrawerHeader(child: Image.asset('assets/logo.jpg', errorBuilder: (c,e,s) => const Icon(Icons.person, size: 80))),
            _menuTile("संस्था की पूरी जानकारी", Icons.info), // 9
            _menuTile("पूर्णमासी कार्यक्रम", Icons.event), // 8
            _menuTile("रेगुलर कार्यक्रम", Icons.calendar_month), // 8
            _menuTile("कार्यक्रम बुकिंग सम्पर्क", Icons.phone), // 10
            _menuTile("गुरु जी की पाठशाला टीम", Icons.group), // 10
          ],
        ),
      ),

      body: Column(
        children: [
          // 4, 5. डोनर पट्टी (Scrolling Marquee)
          Container(
            height: 35,
            color: Colors.redAccent,
            child: const Center(
              child: Text("नवीनतम डोनर: अमित (हिसार) - ₹1100 ... संस्था: गुरु जी की पाठशाला", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),

          // 3, 5. डैशबोर्ड वीडियो (म्यूट बटन के साथ)
          Expanded(
            child: ListView.builder(
              itemCount: videoIds.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: YoutubePlayer(
                    controller: YoutubePlayerController(
                      initialVideoId: videoIds[index],
                      flags: const YoutubePlayerFlags(mute: true, autoPlay: false),
                    ),
                  ),
                );
              },
            ),
          ),

          // 4, 6, 7. डोनेशन और मंथली डोनर बटन
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[100], border: const Border(top: BorderSide(color: Colors.orange))),
            child: Row(
              children: [
                _actionBtn("डोनेशन", Colors.green),
                const SizedBox(width: 10),
                _actionBtn("मंथली डोनर", Colors.blue),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _menuTile(String title, IconData icon) => ListTile(leading: Icon(icon, color: Colors.orange), title: Text(title));

  Widget _actionBtn(String label, Color col) => Expanded(
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: col, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
      onPressed: () {}, // यहाँ UPI सिंक और रशीद का कोड खुलेगा
      child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ),
  );
}
 
