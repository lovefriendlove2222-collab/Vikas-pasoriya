import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MaterialApp(home: HomePage(), debugShowCheckedModeBanner: false));

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // वीडियो लिंक की लिस्ट (एडमिन यहाँ से अपडेट करेगा)
  List<String> videoIds = ['7n9O7p25lYg', 'dQw4w9WgXcQ']; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vikas Pasoriya"), // बिना डेश के नाम
        backgroundColor: Colors.orange,
        actions: [
          // राईट मेनू: एडमिन और डेवलपर सम्पर्क
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text("Admin Login")),
              const PopupMenuItem(child: Text("Dev: Vivek Kaushik\n+91 7206966924")),
            ],
          )
        ],
      ),
      
      // लेफ्ट मेनू (Drawer): संस्था जानकारी, कार्यक्रम, बुकिंग
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Image.network("https://via.placeholder.com/150")), // लोगो यहाँ आएगा
            const ListTile(title: Text("संस्था की पूरी जानकारी")),
            const ListTile(title: Text("पूर्णमासी कार्यक्रम")),
            const ListTile(title: Text("कार्यक्रम बुकिंग")),
            const ListTile(title: Text("गुरु जी की पाठशाला टीम")),
          ],
        ),
      ),

      body: Column(
        children: [
          // डोनर के नाम की चलती पट्टी (Marquee)
          Container(
            height: 30,
            color: Colors.red,
            child: const Center(
              child: Text("धन्यवाद: अमित (हिसार) - ₹501, साहिल (रोहतक) - ₹1100", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          
          // डैशबोर्ड वीडियो प्लेयर
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

          // डोनेशन बटन
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: () {}, child: const Text("डोनेशन"))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(onPressed: () {}, child: const Text("मंथली डोनर"))),
              ],
            ),
          )
        ],
      ),
    );
  }
}
