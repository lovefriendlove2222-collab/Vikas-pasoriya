import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() => runApp(const MaterialApp(home: BadshahApp(), debugShowCheckedModeBanner: false));

class BadshahApp extends StatelessWidget {
  const BadshahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("vikas pasoriya"), // 1. बिना डेश के नाम
        backgroundColor: Colors.orange,
        actions: [const Icon(Icons.admin_panel_settings), const SizedBox(width: 10)],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            // 2. थारा लोगो
            DrawerHeader(child: Icon(Icons.person, size: 80, color: Colors.orange)),
            const ListTile(title: Text("संस्था जानकारी"), leading: Icon(Icons.info)),
            const ListTile(title: Text("कार्यक्रम बुकिंग"), leading: Icon(Icons.phone)),
            const ListTile(title: Text("डेवलपर: विवेक कौशिक (+91 7206966924)")), // 14
          ],
        ),
      ),
      body: Column(
        children: [
          // 4. डोनर पट्टी (Marquee)
          Container(height: 30, color: Colors.red, child: const Center(child: Text("धन्यवाद डोनर: अमित (बाढड़ा) - ₹1100", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          
          // 3, 5. वीडियो डैशबोर्ड
          const Expanded(child: Center(child: Text("यहाँ थारे सारे वीडियो चलेंगे\n(एडमिन सिंक तैयार सै)", textAlign: TextAlign.center, style: TextStyle(fontSize: 18)))),
          
          // 4, 6. डोनेशन बटन
          Padding(padding: const EdgeInsets.all(10), child: Row(children: [
            Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text("डोनेशन", style: TextStyle(color: Colors.white)))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: const Text("मंथली डोनर", style: TextStyle(color: Colors.white)))),
          ])),
        ],
      ),
    );
  }
}
