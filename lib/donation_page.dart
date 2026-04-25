import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MaterialApp(
  title: "Vikas Pasoriya",
  home: VikasApp(),
  debugShowCheckedModeBanner: false,
));

class VikasApp extends StatefulWidget {
  const VikasApp({super.key});
  @override
  State<VikasApp> createState() => _VikasAppState();
}

class _VikasAppState extends State<VikasApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. ऊपर की पट्टी
      appBar: AppBar(
        title: const Text("vikas pasoriya"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),

      // 8, 9, 10. लेफ्ट मेनू (ऊपर कोने में ३ डंडियों पे क्लिक करिये)
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.orange),
              child: Center(child: Icon(Icons.person, size: 70, color: Colors.white)),
            ),
            _menuTile("संस्था की पूरी जानकारी", Icons.info), // 9
            _menuTile("पूर्णमासी कार्यक्रम", Icons.event), // 8
            _menuTile("कार्यक्रम बुकिंग", Icons.phone), // 10
            _menuTile("डेवलपर सम्पर्क", Icons.code), // 14
          ],
        ),
      ),

      // असली माल यहाँ सै (जो सफ़ेद दिख रहा था)
      body: Column(
        children: [
          // 4, 5. डोनर पट्टी (Marquee)
          Container(
            height: 40,
            color: Colors.red,
            width: double.infinity,
            child: const Center(
              child: Text("डोनर: अमित (बाढड़ा) - ₹1100 ... संस्था: गुरु जी की पाठशाला", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ),

          // 3. वीडियो वाला हिस्सा
          const Expanded(
            child: Center(
              child: Text("यूट्यूब डैशबोर्ड चालू सै!\n(एडमिन पैनल से वीडियो बदलें)", 
              textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.black54))),
          ),

          // 4, 6. डोनेशन बटन (ये सबसे नीचे दिखेंगे)
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Row(
              children: [
                Expanded(child: ElevatedButton(
                  onPressed: () => _openForm("डोनेशन"), 
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: const Text("डोनेशन", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(
                  onPressed: () => _openForm("मंथली"), 
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: const Text("मंथली डोनर", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
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
      title: Text("गुरु जी की पाठशाला - $type"),
      content: const Text("डोनर का नाम, गाँव और मोबाइल नम्बर यहाँ भरें।"),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("बंद करें"))],
    ));
  }

  Widget _menuTile(String t, IconData i) => ListTile(leading: Icon(i, color: Colors.orange), title: Text(t));
}
