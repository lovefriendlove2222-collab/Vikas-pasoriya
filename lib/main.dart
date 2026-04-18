import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Firebase को कनेक्ट करने की कोशिश, 5 सेकंड में जवाब ना आए तो भी ऐप खुलेगा
    await Firebase.initializeApp().timeout(const Duration(seconds: 5));
  } catch (e) {
    print("Firebase Error: $e");
  }
  runApp(const VikasApp());
}

class VikasApp extends StatelessWidget {
  const VikasApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vikas Pasoriya Official',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: const Color(0xFFFFF8E1),
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
      appBar: AppBar(
        title: const Text('विकास पासोरिया ऑफिसियल'),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        // यहाँ वही स्पेलिंग है जो थारे Firebase में है
        stream: FirebaseFirestore.instance.collection('settilng').doc('app_config').snapshots(),
        builder: (context, snapshot) {
          
          // डिफ़ॉल्ट डेटा (अगर नेट ना हो तो यो पेज दिखेगा, सफ़ेद स्क्रीन नहीं!)
          String yt = "https://youtube.com/@VikasPasoriya";
          String upi = "your-upi@okicici";
          String info = "पंडित विकास पासोरिया सांस्कृतिक एवं आध्यात्मिक पाठशाला";

          if (snapshot.hasData && snapshot.data!.exists) {
            var d = snapshot.data!.data() as Map<String, dynamic>;
            yt = d['youtube'] ?? yt;
            upi = d['upi'] ?? upi;
            info = d['about'] ?? info;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                // थारा किला वाला आइकॉन
                const Icon(Icons.fort_rounded, size: 120, color: Colors.deepOrange),
                const SizedBox(height: 10),
                const Text('हरि ॐ जी!', 
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                
                const SizedBox(height: 30),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Text(info, 
                    textAlign: TextAlign.center, 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                ),

                const SizedBox(height: 40),

                // डोनेशन बटन
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange, 
                      minimumSize: const Size(double.infinity, 70),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35))
                    ),
                    icon: const Icon(Icons.volunteer_activism, color: Colors.white, size: 30),
                    label: const Text('सहयोग राशि दें', 
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    onPressed: () => _pay(upi),
                  ),
                ),

                const SizedBox(height: 25),

                // यूट्यूब बटन
                InkWell(
                  onTap: () => _launch(yt),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.red.withOpacity(0.3))
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.video_library, color: Colors.red),
                        SizedBox(width: 10),
                        Text("यूट्यूब चैनल देखें", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  _launch(url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  _pay(upi) async {
    final url = "upi://pay?pa=$upi&pn=Vikas&cu=INR";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
