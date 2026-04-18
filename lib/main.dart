import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Firebase को जगाने की कोशिश
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase Setup Error: $e");
  }
  runApp(const VikasOfficialApp());
}

class VikasOfficialApp extends StatelessWidget {
  const VikasOfficialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vikas Pasoriya Official',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        textTheme: GoogleFonts.hindTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text('विकास पासोरिया ऑफिसियल'),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
        elevation: 10,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // थारे Firestore का नाम 'menus' सै
        stream: FirebaseFirestore.instance.collection('menus').snapshots(),
        builder: (context, snapshot) {
          
          // १. अगर डेटा अभी रास्ते में है
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          }

          // २. अगर कोई गड़बड़ है (यो स्क्रीन पै लिखा आएगा)
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text("गड़बड़: ${snapshot.error}\n\nभाई, Firebase Rules चैक कर!", 
                  textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              ),
            );
          }

          // ३. अगर डेटा मिल गया
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            var doc = snapshot.data!.docs.first.data() as Map<String, dynamic>;
            String mainTitle = doc['title'] ?? "हरि ॐ जी!";
            String subTitle = doc['desc'] ?? "टीम विकास पासोरिया";

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.music_note_rounded, size: 100, color: Colors.deepOrange),
                  const SizedBox(height: 20),
                  Text(mainTitle, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.brown)),
                  const SizedBox(height: 10),
                  Text(subTitle, style: const TextStyle(fontSize: 20, color: Colors.orangeGrey)),
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
                    icon: const Icon(Icons.play_circle_fill),
                    label: const Text("यूट्यूब चैनल", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            );
          }

          // ४. अगर डेटाबेस कति खाली है
          return const Center(
            child: Text("भाई, Firestore में 'menus' नाम का कलेक्शन नी मिल्या!"),
          );
        },
      ),
    );
  }
}
