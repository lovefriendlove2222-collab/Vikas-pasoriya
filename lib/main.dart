import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MaterialApp(home: VikasPasoriyaApp(), debugShowCheckedModeBanner: false));

class VikasPasoriyaApp extends StatefulWidget {
  const VikasPasoriyaApp({super.key});
  @override
  State<VikasPasoriyaApp> createState() => _VikasPasoriyaAppState();
}

class _VikasPasoriyaAppState extends State<VikasPasoriyaApp> {
  // 3. वीडियो लिंक की लिस्ट (एडमिन यहाँ से सिंक करेगा)
  final List<String> videoIds = ['VIDEO_ID_1', 'VIDEO_ID_2']; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. बिना डेश के नाम
      appBar: AppBar(
        title: const Text("Vikas Pasoriya"), 
        backgroundColor: Colors.orange,
        actions: [
          // 11. राईट मेनू - एडमिन लॉगिन
          PopupMenuButton(
            icon: const Icon(Icons.admin_panel_settings),
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text("Admin Login (Password Required)")),
              // 14. एप डेवलोपर सम्पर्क
              PopupMenuItem(child: Text("Developer: Vivek Kaushik \n+91 7206966924")),
            ],
          ),
        ],
      ),

      // 8, 9, 10. लेफ्ट मेनू (Drawer)
      drawer: Drawer(
        child: ListView(
          children: [
            // 2. लोगो यहाँ दिखेगा
            DrawerHeader(child: Image.asset('assets/logo.jpg')), 
            ListTile(title: const Text("संस्था की पूरी जानकारी"), onTap: () {}),
            ListTile(title: const Text("पूर्णमासी कार्यक्रम"), onTap: () {}),
            ListTile(title: const Text("रेगुलर कार्यक्रम"), onTap: () {}),
            ListTile(title: const Text("कार्यक्रम बुकिंग (सम्पर्क)"), onTap: () {}),
            ListTile(title: const Text("गुरु जी की पाठशाला टीम"), onTap: () {}),
          ],
        ),
      ),

      body: Column(
        children: [
          // 4, 5. डोनर के नाम की पट्टी (Scrolling Marquee)
          Container(
            height: 40,
            color: Colors.redAccent,
            child: const Center(child: Text("नवीनतम डोनर: विवेक (बाढड़ा) - ₹1100 ... धन्यवाद", style: TextStyle(color: Colors.white))),
          ),

          // 3. डैशबोर्ड पर वीडियो प्लेयर
          Expanded(
            child: ListView.builder(
              itemCount: videoIds.length,
              itemBuilder: (context, index) {
                return YoutubePlayer(
                  controller: YoutubePlayerController(
                    initialVideoId: videoIds[index],
                    flags: const YoutubePlayerFlags(mute: true, autoPlay: false),
                  ),
                );
              },
            ),
          ),

          // 4. डोनेशन बटन
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: () {}, child: const Text("डोनेशन (One Time)"))),
              Expanded(child: ElevatedButton(onPressed: () {}, child: const Text("मंथली डोनर"))),
            ],
          )
        ],
      ),
    );
  }
}
