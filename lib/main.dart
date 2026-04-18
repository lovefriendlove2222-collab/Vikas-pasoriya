import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Firebase शुरू करने की कोशिश
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase Initialize Error: $e");
  }
  runApp(const VikasApp());
}

class VikasApp extends StatelessWidget {
  const VikasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        textTheme: GoogleFonts.hindTextTheme(),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  // यूट्यूब खोलने का फंक्शन
  Future<void> _launchYoutube() async {
    final Uri url = Uri.parse('https://youtube.com/@VikasPasoriya');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text('विकास पासोरिया ऑफिसियल'),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      // यहाँ से डेटा आवेगा
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('menus').snapshots(),
        builder: (context, snapshot) {
          
          // १. अगर डेटा अभी लोड हो रहा है
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // २. अगर कोई एरर आ गया (यो स्क्रीन पै लाल रंग में दिखेगा)
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text("गड़बड़: ${snapshot.error}", 
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center),
              ),
            );
          }

          // ३. अगर डेटा मिल गया (Success!)
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
            String title = data['title'] ?? "हरि ॐ जी!";
            String desc = data['desc'] ?? "टीम विकास पासोरिया";

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fort_rounded, size: 100, color: Colors.deepOrange),
                  const SizedBox(height: 30),
                  Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    onPressed: _launchYoutube,
                    icon: const Icon(Icons.video_library, color: Colors.white),
                    label: const Text("यूट्यूब चैनल", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ],
              ),
            );
          }

          // ४. अगर डेटाबेस से कुछ नी मिल्या
          return const Center(child: Text("डेटाबेस में कोई डेटा कोनी भाई!"));
        },
      ),
    );
  }
}
