import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) { print(e); }
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
        scaffoldBackgroundColor: const Color(0xFFFFF8E1),
      ),
      // यहाँ सीधा होम स्क्रीन लोड होगी
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('विकास पासोरिया ऑफिसियल'), backgroundColor: Colors.deepOrange),
      body: StreamBuilder(
        // यहाँ 5 सेकंड का टाइमआउट सैट सै ताकि सफ़ेद स्क्रीन न आए
        stream: FirebaseFirestore.instance.collection('settings').doc('app_config').snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
          
          // डिफ़ॉल्ट डेटा - अगर Firebase फेल हो जाए तो ये दिखेगा
          String yt = "https://youtube.com/@VikasPasoriya";
          String upi = "paytmqr123@paytm";

          if (snap.hasData && snap.data!.exists) {
            var d = snap.data!;
            yt = d['youtube'] ?? yt;
            upi = d['upi'] ?? upi;
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fort_rounded, size: 100, color: Colors.deepOrange),
                const Text('हरि ॐ जी!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                  onPressed: () => _launch(yt),
                  child: const Text("यूट्यूब चैनल", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _launch(u) async { if (await canLaunchUrl(Uri.parse(u))) await launchUrl(Uri.parse(u)); }
}
