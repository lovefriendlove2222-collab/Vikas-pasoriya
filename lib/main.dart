import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) { print(e); }
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen()));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(title: const Text('विकास पासोरिया ऑफिसियल'), backgroundColor: Colors.deepOrange),
      body: StreamBuilder<DocumentSnapshot>(
        // यहाँ वही स्पेलिंग है जो थारे Firebase में सै
        stream: FirebaseFirestore.instance.collection('settilng').doc('app_config').snapshots(),
        builder: (context, snapshot) {
          
          // डिफ़ॉल्ट डेटा (अगर नेट नी सै तो यो दिखेगा)
          String yt = "https://youtube.com/@VikasPasoriya";
          String info = "पंडित विकास पासोरिया सांस्कृतिक एवं आध्यात्मिक पाठशाला";

          // अगर Firebase तै डेटा मिल गया तो उसे लोड करो
          if (snapshot.hasData && snapshot.data!.exists) {
            var d = snapshot.data!.data() as Map<String, dynamic>;
            yt = d['youtube'] ?? yt;
            info = d['about'] ?? info;
          }

          // सफ़ेद स्क्रीन तै बचण के लिए सीधा डिज़ाइन दिखाओ
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fort_rounded, size: 100, color: Colors.deepOrange),
                const Text('हरि ॐ जी!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(info, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                  onPressed: () => launchUrl(Uri.parse(yt)),
                  child: const Text("यूट्यूब चैनल", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
