import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MaterialApp(
  home: VikasFinalApp(),
  debugShowCheckedModeBanner: false,
));

class VikasFinalApp extends StatefulWidget {
  const VikasFinalApp({super.key});
  @override
  State<VikasFinalApp> createState() => _VikasFinalState();
}

class _VikasFinalState extends State<VikasFinalApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. ऊपर की पट्टी (एडमिन पैनल का बटन यहाँ सै)
      appBar: AppBar(
        title: const Text("vikas pasoriya"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, size: 30),
            onPressed: () => _openAdminPanel(), // 11. एडमिन पैनल यहाँ तै खुलेगा
          )
        ],
      ),

      // 8, 9, 10. लेफ्ट मेनू (३ डंडियों पे क्लिक करिये, सारे ऑप्शन यहाँ सैं)
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.orange),
              child: Center(child: Icon(Icons.account_circle, size: 80, color: Colors.white)),
            ),
            _menuTile("संस्था की पूरी जानकारी", Icons.info, () {}),
            _menuTile("पूर्णमासी कार्यक्रम", Icons.event, () {}),
            _menuTile("कार्यक्रम बुकिंग", Icons.phone, () => launchUrl(Uri.parse("tel:+917206966924"))),
            _menuTile("डेवलपर सम्पर्क", Icons.code, () => launchUrl(Uri.parse("tel:+917206966924"))),
          ],
        ),
      ),

      body: Column(
        children: [
          // 4, 5. डोनर पट्टी (Marquee)
          Container(
            height: 40,
            color: Colors.red,
            width: double.infinity,
            child: const Center(
              child: Text("नवीनतम डोनर: अमित (बाढड़ा) - ₹1100 ... संस्था: गुरु जी की पाठशाला", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ),

          // 3. वीडियो वाला हिस्सा (जो सफ़ेद दिख रहा था)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_fill, size: 100, color: Colors.orange),
                  Text("यूट्यूब डैशबोर्ड चालू सै!\nसारे ऑप्शन इब लोड हो रहे सैं", 
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          // 4, 6. डोनेशन और मंथली डोनर बटन (सबसे नीचे पट्टी)
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
            child: Row(
              children: [
                Expanded(child: _actionBtn("डोनेशन", Colors.green, () => _openForm("डोनेशन"))),
                const SizedBox(width: 10),
                Expanded(child: _actionBtn("मंथली डोनर", Colors.blue, () => _openForm("मंथली"))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // एडमिन पैनल का ऑप्शन
  void _openAdminPanel() {
    showDialog(context: context, builder: (context) => const AlertDialog(
      title: Text("11. एडमिन पैनल लॉगिन"),
      content: TextField(decoration: InputDecoration(hintText: "पासवर्ड भरें")),
    ));
  }

  // डोनर रशीद फॉर्म (पॉइंट 12)
  void _openForm(String title) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("गुरु जी की पाठशाला - $title"),
      content: const Text("डोनर का नाम, गाँव और मोबाइल यहाँ भरें।"),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("बंद करें"))],
    ));
  }

  Widget _menuTile(String t, IconData i, VoidCallback onTap) => ListTile(leading: Icon(i, color: Colors.orange), title: Text(t), onTap: onTap);
  Widget _actionBtn(String l, Color c, VoidCallback onTap) => ElevatedButton(
    onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: c, padding: const EdgeInsets.symmetric(vertical: 15)),
    child: Text(l, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)));
}
