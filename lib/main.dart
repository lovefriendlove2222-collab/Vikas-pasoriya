import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

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
  // 3. वीडियो लिंक लिस्ट (एडमिन पैनल से हजारों लिंक जुड़ेंगे)
  List<String> videoIds = ['7n9O7p25lYg', 'dQw4w9WgXcQ'];
  
  // 4, 5. डोनर लिस्ट (ऑनलाइन सिंक होकर यहाँ चलेगी)
  String tickerText = "नवीनतम डोनर: अमित (बाढड़ा) - ₹1100 (गुरु जी की पाठशाला) - 25/04/2026 14:30 ... हृदय की गहराइयों से धन्यवाद!";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. ऐप बार (नाम बिना डेश के)
      appBar: AppBar(
        title: const Text("vikas pasoriya", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        actions: [
          // 11, 14. राइट मेनू
          PopupMenuButton(itemBuilder: (context) => [
            const PopupMenuItem(value: 'admin', child: Text("11. एडमिन लॉगिन")),
            PopupMenuItem(value: 'dev', child: const Text("14. डेवलपर सम्पर्क")),
          ], onSelected: (v) => _handleRightMenu(v)),
        ],
      ),

      // 8, 9, 10. लेफ्ट मेनू (Drawer)
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(decoration: BoxDecoration(color: Colors.orange), child: Icon(Icons.person, size: 80, color: Colors.white)),
            _menuTile("9. संस्था की पूरी जानकारी", Icons.info),
            _menuTile("8. पूर्णमासी कार्यक्रम", Icons.calendar_today),
            _menuTile("8. रेगुलर कार्यक्रम", Icons.event),
            _menuTile("10. कार्यक्रम बुकिंग", Icons.phone_callback),
            _menuTile("10. गुरु जी की पाठशाला टीम", Icons.group),
          ],
        ),
      ),

      body: Column(
        children: [
          // 4, 5. डोनर पट्टी (Marquee)
          Container(
            height: 35, color: Colors.red, width: double.infinity,
            child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Center(
              child: Text(tickerText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          ),

          // 3. वीडियो डैशबोर्ड (यूट्यूब/फेसबुक)
          Expanded(
            child: ListView.builder(
              itemCount: videoIds.length,
              itemBuilder: (context, i) => _videoCard(videoIds[i]),
            ),
          ),

          // 4, 6, 7. डोनेशन और मंथली डोनर बटन (सबसे नीचे)
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                _actionBtn("डोनेशन", Colors.green, () => _openDonationForm("सिंगल")),
                const SizedBox(width: 10),
                _actionBtn("मंथली डोनर", Colors.blue, () => _openDonationForm("मंथली")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. वीडियो कार्ड म्यूट बटन के साथ
  Widget _videoCard(String id) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: YoutubePlayer(
        controller: YoutubePlayerController(initialVideoId: id, flags: const YoutubePlayerFlags(mute: true, autoPlay: false)),
        showVideoProgressIndicator: true,
      ),
    );
  }

  // 4, 12. डिजिटल रशीद फॉर्म
  void _openDonationForm(String type) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("$type डोनेशन (UPI)"),
      content: Column(mainAxisSize: MainAxisSize.min, children: const [
        Text("UPI ID: vikas@upi (एडमिन बदल सकता है)"),
        TextField(decoration: InputDecoration(hintText: "डोनर नाम")),
        TextField(decoration: InputDecoration(hintText: "गाँव")),
        TextField(decoration: InputDecoration(hintText: "मोबाइल")),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("पेमेंट कन्फर्म (रशीद जनरेट करें)"))],
    ));
  }

  void _handleRightMenu(String val) {
    if (val == 'dev') {
      launchUrl(Uri.parse("tel:+917206966924")); // 14. डेवलपर विवेक कौशिक
    } else {
      // 11. एडमिन पैनल लॉगिन लॉजिक
    }
  }

  Widget _menuTile(String t, IconData i) => ListTile(leading: Icon(i, color: Colors.orange), title: Text(t));
  Widget _actionBtn(String l, Color c, VoidCallback f) => Expanded(child: ElevatedButton(
    onPressed: f, style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white), child: Text(l)));
}
