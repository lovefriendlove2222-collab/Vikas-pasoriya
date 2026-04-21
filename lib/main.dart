import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MaterialApp(
  home: VikasApp(),
  debugShowCheckedModeBanner: false,
  title: "vikas pasoriya", // 1. बिना डेश के नाम
));

class VikasApp extends StatefulWidget {
  const VikasApp({super.key});
  @override
  State<VikasApp> createState() => _VikasAppState();
}

class _VikasAppState extends State<VikasApp> {
  // 3. वीडियो लिंक्स (यहाँ जितने चाहो उतने लिंक डालो)
  final List<String> videoLinks = ['7n9O7p25lYg', 'dQw4w9WgXcQ'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vikas Pasoriya"), // 1. ऐप नाम
        backgroundColor: Colors.orange,
        actions: [
          // 11. राईट मेनू (एडमिन लॉगिन)
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => _showAdminPanel(context),
          ),
        ],
      ),
      
      // 8-10. लेफ्ट मेनू (Drawer)
      drawer: Drawer(
        child: ListView(
          children: [
            // 2. थारा लोगो
            DrawerHeader(child: Image.network("https://tinyurl.com/vikas-logo")), 
            _menuItem("संस्था जानकारी", Icons.info),
            _menuItem("पूर्णमासी कार्यक्रम", Icons.calendar_month),
            _menuItem("कार्यक्रम बुकिंग", Icons.phone),
            _menuItem("गुरु जी की पाठशाला", Icons.group), //
            const Divider(),
            // 14. ऐप डेवलपर (तेरा नाम और नम्बर)
            const ListTile(
              title: Text("डेवलपर: विवेक कौशिक"),
              subtitle: Text("+91 7206966924"), //
              leading: Icon(Icons.code),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // 4-6. डोनर पट्टी (Scrolling Marquee)
          Container(
            height: 35,
            color: Colors.red,
            child: const Center(
              child: Text("नवीनतम डोनर: साहिल (बाढड़ा) - ₹2100 ... धन्यवाद!", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),

          // 3. डैशबोर्ड वीडियो (YouTube सिंक)
          Expanded(
            child: ListView.builder(
              itemCount: videoLinks.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: YoutubePlayer(
                    controller: YoutubePlayerController(
                      initialVideoId: videoLinks[index],
                      flags: const YoutubePlayerFlags(mute: true, autoPlay: false),
                    ),
                  ),
                );
              },
            ),
          ),

          // 4. डोनेशन बटन
          Padding(
            padding: const EdgeInsets.all(8.0),
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

  Widget _menuItem(String title, IconData icon) => ListTile(leading: Icon(icon), title: Text(title));
  
  Widget _actionBtn(String label, Color col) => Expanded(
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: col, foregroundColor: Colors.white),
      onPressed: () {}, 
      child: Text(label),
    ),
  );

  // 11. एडमिन पैनल (पासवर्ड के साथ)
  void _showAdminPanel(BuildContext context) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("एडमिन लॉगिन"),
      content: const TextField(decoration: InputDecoration(hintText: "पासवर्ड डालें")),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("लॉगिन"))],
    ));
  }
}
