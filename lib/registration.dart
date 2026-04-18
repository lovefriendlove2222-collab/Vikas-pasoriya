import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) { print(e); }
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false, 
    home: VikasApp()
  ));
}

class VikasApp extends StatelessWidget {
  const VikasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text('विकास पासोरिया ऑफिसियल'),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      // StreamBuilder में हमने वही 'menus' नाम लिखा है जो थारे Firebase में है
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('menus').snapshots(),
        builder: (context, snapshot) {
          
          // डिफ़ॉल्ट डेटा (अगर नेट ना हो तो सफ़ेद स्क्रीन नी आओगी, यो दिखेगा)
          String title = "हरि ॐ जी!";
          String desc = "टीम विकास पासोरिया";

          // अगर Firebase तै डेटा मिल गया तो उसे अपडेट करो
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
            title = data['title'] ?? title; // Firebase में 'title' फील्ड
            desc = data['desc'] ?? desc;   // Firebase में 'desc' फील्ड
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fort_rounded, size: 100, color: Colors.deepOrange),
                const SizedBox(height: 20),
                Text(title, style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, minimumSize: const Size(200, 50)),
                  onPressed: () => _launchURL("https://youtube.com/@VikasPasoriya"),
                  icon: const Icon(Icons.video_library, color: Colors.white),
                  label: const Text("यूट्यूब चैनल", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
