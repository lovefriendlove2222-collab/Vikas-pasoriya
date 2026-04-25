import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MaterialApp(
  title: "vikas pasoriya", // 1. बिना डेश के नाम
  home: VikasApp(),
  debugShowCheckedModeBanner: false,
));

class VikasApp extends StatefulWidget {
  const VikasApp({super.key});
  @override
  State<VikasApp> createState() => _VikasAppState();
}

class _VikasAppState extends State<VikasApp> {
  // 3. वीडियो लिंक्स (एडमिन पैनल से जुड़ेंगे)
  List<String> videoIds = ['7n9O7p25lYg', 'dQw4w9WgXcQ'];
  
  // 4, 5. डोनर पट्टी का डेटा
  String donorNews = "नवीनतम डोनर: अमित (बाढड़ा) - ₹1100 (गुरु जी की पाठशाला) ... हृदय की गहराइयों से बार-बार धन्यवाद!";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. ऐप बार (राइट मेनू के साथ)
      appBar: AppBar(
        title: const Text("vikas pasoriya"),
        backgroundColor: Colors.orange,
        actions: [
          PopupMenuButton(itemBuilder: (context) => [
            const PopupMenuItem(value: 'admin', child: Text("11. एडमिन लॉगिन")),
            const PopupMenuItem(value: 'dev', child: Text("14. डेवलपर सम्पर्क")),
          ], onSelected: (v) => _handleMenu(v)),
        ],
      ),

      // 8, 9, 10. लेफ्ट मेनू (सारे ऑप्शन यहाँ हैं)
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(decoration: BoxDecoration(color: Colors.orange), child: Icon(Icons.person, size: 70, color: Colors.white)),
            _drawerTile("9. संस्था की पूरी जानकारी", Icons.info),
            _drawerTile("8. पूर्णमासी कार्यक्रम", Icons.event),
            _drawerTile("10. कार्यक्रम बुकिंग", Icons.phone_callback),
            _drawerTile("10. पाठशाला टीम", Icons.group),
          ],
        ),
      ),

      body: Column(
        children: [
          // 4, 5. डोनर पट्टी (Marquee)
          Container(height: 35, color: Colors.red, width: double.infinity,
            child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Center(
              child: Text(donorNews, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),

          // 3. वीडियो डैशबोर्ड (Mute बटन के साथ)
          Expanded(child: ListView.builder(itemCount: videoIds.length,
            itemBuilder: (context, i) => _videoItem(videoIds[i]))),

          // 4, 6. डोनेशन और मंथली डोनर बटन (सबसे नीचे)
          Container(padding: const EdgeInsets.all(12), color: Colors.white,
            child: Row(children: [
              _bottomBtn("डोनेशन", Colors.green, () => _openForm("डोनेशन")),
              const SizedBox(width: 10),
              _bottomBtn("मंथली डोनर", Colors.blue, () => _openForm("मंथली")),
            ])),
        ],
      ),
    );
  }

  void _handleMenu(String v) {
    if (v == 'dev') launchUrl(Uri.parse("tel:+917206966924")); // 14. विवेक कौशिक
    // 11. एडमिन लॉगिन लॉजिक यहाँ आएगा
  }

  Widget _videoItem(String id) => Card(margin: const EdgeInsets.all(8),
    child: YoutubePlayer(controller: YoutubePlayerController(initialVideoId: id, flags: const YoutubePlayerFlags(mute: true, autoPlay: false))));

  void _openForm(String t) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("गुरु जी की पाठशाला - $t"),
      content: const Text("डोनर नाम, गाँव और मोबाइल भरें। पेमेंट के बाद रशीद मिलेगी।"),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("बंद करें"))],
    ));
  }

  Widget _drawerTile(String t, IconData i) => ListTile(leading: Icon(i, color: Colors.orange), title: Text(t));
  Widget _bottomBtn(String l, Color c, VoidCallback f) => Expanded(child: ElevatedButton(onPressed: f,
    style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white), child: Text(l)));
}
