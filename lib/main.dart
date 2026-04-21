import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MaterialApp(home: VikasHome(), debugShowCheckedModeBanner: false));

class VikasHome extends StatefulWidget {
  const VikasHome({super.key});
  @override
  State<VikasHome> createState() => _VikasHomeState();
}

class _VikasHomeState extends State<VikasHome> {
  // 3. वीडियो लिंक (एडमिन यहाँ से सिंक करेगा)
  final List<String> vids = ['7n9O7p25lYg', 'dQw4w9WgXcQ']; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("vikas pasoriya"), // 1. बिना डेश के नाम
        backgroundColor: Colors.orange,
        actions: [
          // 11, 14. राईट मेनू
          PopupMenuButton(itemBuilder: (context) => [
            const PopupMenuItem(child: Text("एडमिन लॉगिन")),
            const PopupMenuItem(child: Text("डेवलपर: विवेक कौशिक \n+91 7206966924")),
          ]),
        ],
      ),
      // 8, 9, 10. लेफ्ट मेनू (Drawer)
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Image.asset('assets/logo.jpg', errorBuilder: (c,e,s) => const Icon(Icons.person, size: 80))),
            const ListTile(title: Text("संस्था जानकारी"), leading: Icon(Icons.info)),
            const ListTile(title: Text("कार्यक्रम बुकिंग"), leading: Icon(Icons.phone)),
            const ListTile(title: Text("गुरु जी की पाठशाला"), leading: Icon(Icons.school)),
          ],
        ),
      ),
      body: Column(
        children: [
          // 4, 5. डोनर पट्टी
          Container(height: 35, color: Colors.red, child: const Center(child: Text("धन्यवाद डोनर: अमित (बाढड़ा) - ₹1100", style: TextStyle(color: Colors.white)))),
          // 3. वीडियो प्लेयर
          Expanded(child: ListView.builder(itemCount: vids.length, itemBuilder: (context, i) => YoutubePlayer(controller: YoutubePlayerController(initialVideoId: vids[i], flags: const YoutubePlayerFlags(mute: true))))),
          // 4. डोनेशन बटन
          Padding(padding: const EdgeInsets.all(8.0), child: Row(children: [
            Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text("डोनेशन", style: TextStyle(color: Colors.white)))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: const Text("मंथली डोनर", style: TextStyle(color: Colors.white)))),
          ])),
        ],
      ),
    );
  }
}
 
