import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MaterialApp(home: VikasApp(), debugShowCheckedModeBanner: false));

class VikasApp extends StatefulWidget {
  const VikasApp({super.key});
  @override
  State<VikasApp> createState() => _VikasAppState();
}

class _VikasAppState extends State<VikasApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. ऊपर की पट्टी (नाम के साथ)
      appBar: AppBar(
        title: const Text("vikas pasoriya"), 
        backgroundColor: Colors.orange,
        actions: [IconButton(icon: const Icon(Icons.admin_panel_settings), onPressed: () {})], // 11. एडमिन
      ),

      // 8, 9, 10. लेफ्ट मेनू (३ डंडियों पे क्लिक करते ही दिखेगा)
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(decoration: BoxDecoration(color: Colors.orange), child: Icon(Icons.person, size: 60, color: Colors.white)),
            _menuTile("संस्था की जानकारी", Icons.info), // 9
            _menuTile("पूर्णमासी कार्यक्रम", Icons.event), // 8
            _menuTile("कार्यक्रम बुकिंग", Icons.phone), // 10
            _menuTile("डेवलपर सम्पर्क", Icons.code), // 14
          ],
        ),
      ),

      // असली माल यहाँ सै (जो थारे में सफ़ेद दिख रहा था)
      body: Column(
        children: [
          // 4, 5. डोनर पट्टी (Marquee)
          Container(height: 35, color: Colors.red, width: double.infinity, child: const Center(
            child: Text("डोनर: अमित (बाढड़ा) - ₹1100 ... संस्था: गुरु जी की पाठशाला", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),

          // 3. वीडियो डैशबोर्ड का हिस्सा
          const Expanded(child: Center(child: Text("यहाँ यूट्यूब वीडियो चलेंगे\n(एडमिन पैनल से लिंक डालें)", 
            textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey)))),

          // 4, 6. डोनेशन और मंथली डोनर बटन (इब ये सबसे नीचे पक्के दिखेंगे)
          Container(
            padding: const EdgeInsets.all(15),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(child: ElevatedButton(
                  onPressed: () => _openForm("डोनेशन"), 
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: const Text("डोनेशन", style: TextStyle(color: Colors.white, fontSize: 16)))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(
                  onPressed: () => _openForm("मंथली"), 
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: const Text("मंथली डोनर", style: TextStyle(color: Colors.white, fontSize: 16)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // डोनर फॉर्म जो बटन दबाते ही खुलेगा
  void _openForm(String type) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("$type फॉर्म"),
      content: const Text("डोनर का नाम, गाँव और मोबाइल नम्बर यहाँ भरें।"),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("बंद करें"))],
    ));
  }

  Widget _menuTile(String t, IconData i) => ListTile(leading: Icon(i, color: Colors.orange), title: Text(t));
}
