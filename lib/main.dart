import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase Error: $e");
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
        // इब यो 'settings' तै डेटा ठावैगा
        stream: FirebaseFirestore.instance.collection('settings').snapshots(),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          }

          if (snapshot.hasError) {
            return Center(child: Text("गड़बड़: ${snapshot.error}"));
          }

          // अगर settings में डेटा मिल गया
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
            
            // डेटाबेस में 'title' और 'desc' नाम के फील्ड होणे जरूरी सैं
            String title = data['title'] ?? "विकास पासोरिया";
            String desc = data['desc'] ?? "राम राम भाईयो!";

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.music_video, size: 100, color: Colors.deepOrange),
                  const SizedBox(height: 20),
                  Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.brown)),
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
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    },
                    icon: const Icon(Icons.play_circle_filled),
                    label: const Text("यूट्यूब चैनल", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            );
          }

          // अगर settings कलेक्शन खाली सै
          return const Center(
            child: Text("भाई, 'settings' में डेटा डालणा पड़ेगा!"),
          );
        },
      ),
    );
  }
}
