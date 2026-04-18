import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase Initialize Error: $e");
  }
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: VikasApp(),
  ));
}

class VikasApp extends StatelessWidget {
  const VikasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text('विकास पासोरिया ऑफिसियल'),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // थारे डेटाबेस का नाम 'menus' सै
        stream: FirebaseFirestore.instance.collection('menus').snapshots(),
        builder: (context, snapshot) {
          
          // १. जब तक डेटा आ रहा है (Loading)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          }

          // २. अगर कोई गड़बड़ है (Error)
          if (snapshot.hasError) {
            return Center(child: Text("गड़बड़: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }

          // ३. अगर डेटा मिल गया
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
            String title = data['title'] ?? "हरि ॐ जी!";
            String desc = data['desc'] ?? "टीम विकास पासोरिया";

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.music_video, size: 100, color: Colors.deepOrange),
                  const SizedBox(height: 20),
                  Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.brown)),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    onPressed: () async {
                      final url = Uri.parse('https://youtube.com/@VikasPasoriya');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.play_circle_filled),
                    label: const Text("यूट्यूब चैनल", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            );
          }

          // ४. अगर सब सही है पर डेटाबेस खाली है
          return const Center(child: Text("भाई, Firestore में डेटा नी मिल्या!"));
        },
      ),
    );
  }
}
