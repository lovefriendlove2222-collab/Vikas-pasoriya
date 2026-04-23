import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

void main() => runApp(const MaterialApp(home: VikasApp(), debugShowCheckedModeBanner: false));

class VikasApp extends StatefulWidget {
  const VikasApp({super.key});
  @override
  State<VikasApp> createState() => _VikasAppState();
}

class _VikasAppState extends State<VikasApp> {
  // 3. वीडियो लिंक्स (यूट्यूब/फेसबुक) - एडमिन यहाँ से लिंक बढ़ा सकेगा
  List<String> videoIds = ['7n9O7p25lYg', 'dQw4w9WgXcQ']; 
  String instLogo = "गुरु जी की पाठशाला"; // संस्था का नाम

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("vikas pasoriya"), // 1. नाम
        backgroundColor: Colors.orange,
        actions: [
          PopupMenuButton(itemBuilder: (context) => [
            const PopupMenuItem(child: Text("11. एडमिन लॉगिन")), // पासवर्ड वाला पैनल
            PopupMenuItem(child: const Text("14. डेवलपर: विवेक कौशिक \n+91 7206966924"),
              onTap: () => launchUrl(Uri.parse("tel:+917206966924"))),
          ]),
        ],
      ),

      // 8, 9, 10. लेफ्ट मेनू रिक्वायरमेंट्स
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Icon(Icons.person, size: 80, color: Colors.orange)),
            _menuTile("9. संस्था की पूरी जानकारी", Icons.info),
            _menuTile("8. पूर्णमासी कार्यक्रम", Icons.event),
            _menuTile("10. कार्यक्रम बुकिंग", Icons.phone),
            _menuTile("10. पाठशाला टीम", Icons.group),
          ],
        ),
      ),

      body: Column(
        children: [
          // 4, 5. डोनर पट्टी (Marquee style)
          Container(height: 40, color: Colors.red, child: const Center(
            child: Text("धन्यवाद डोनर: अमित (बाढड़ा) - ₹1100 ... संस्था: गुरु जी की पाठशाला", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),

          // 3. वीडियो डैशबोर्ड (Mute/Unmute)
          Expanded(child: ListView.builder(itemCount: videoIds.length, itemBuilder: (context, i) {
            return Padding(padding: const EdgeInsets.all(8.0), child: YoutubePlayer(
              controller: YoutubePlayerController(initialVideoId: videoIds[i], 
              flags: const YoutubePlayerFlags(mute: true, autoPlay: false))));
          })),

          // 4, 6, 7. डोनेशन और मंथली डोनर बटन
          Container(padding: const EdgeInsets.all(12), color: Colors.grey[200], child: Row(children: [
            _btn("डोनेशन", Colors.green, () => _showDonationDialog(context, "सिंगल")),
            const SizedBox(width: 10),
            _btn("मंथली डोनर", Colors.blue, () => _showDonationDialog(context, "मंथली")),
          ])),
        ],
      ),
    );
  }

  // 4, 12. डोनर रशीद और डिटेल फॉर्म
  void _showDonationDialog(BuildContext context, String type) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("$type डोनेशन"),
      content: Column(mainAxisSize: MainAxisSize.min, children: const [
        TextField(decoration: InputDecoration(hintText: "नाम")),
        TextField(decoration: InputDecoration(hintText: "गाँव")),
        TextField(decoration: InputDecoration(hintText: "मोबाइल नम्बर")),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("पेमेंट कन्फर्म (रशीद जनरेट)"))],
    ));
  }

  Widget _menuTile(String t, IconData i) => ListTile(leading: Icon(i, color: Colors.orange), title: Text(t));
  Widget _btn(String l, Color c, VoidCallback action) => Expanded(child: ElevatedButton(
    onPressed: action, style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white), child: Text(l)));
}
