import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Firebase को शुरू करें
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase Error: $e");
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
      backgroundColor: const Color(0xFFFFF8E1), // थारा पसंदीदा क्रीम कलर
      appBar: AppBar(
        title: const Text('विकास पासोरिया ऑफिसियल'),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      // यहाँ ध्यान देना भाई, 'menus' वही नाम है जो थारे डेटाबेस में है
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('menus').snapshots(),
        builder: (context, snapshot) {
          
          // डिफ़ॉल्ट डेटा (अगर नेट धीमा हो तो सफ़ेद स्क्रीन की जगह ये दिखेगा)
          String mainTitle = "हरि ॐ जी!";
          String description = "टीम विकास पासोरिया";

          // अगर Firebase से डेटा मिल गया
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            var doc = snapshot.data!.docs.first.data() as Map<String, dynamic>;
            // थारे Firebase के फील्ड्स: 'title' और 'desc'
            mainTitle = doc['title'] ?? mainTitle;
            description = doc['desc'] ?? description;
          }

          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fort_rounded, size: 100, color: Colors.deepOrange),
                  const SizedBox(height: 20),
                  Text(mainTitle, 
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text(description, 
                      textAlign: TextAlign.center, 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 40),
                  // यूट्यूब बटन
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      minimumSize: const Size(250, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () => _launch("https://youtube.com/@VikasPasoriya"),
                    icon: const Icon(Icons.video_library, color: Colors.white),
                    label: const Text("यूट्यूब चैनल", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // लिंक खोलने के लिए फंक्शन
  void _launch(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
