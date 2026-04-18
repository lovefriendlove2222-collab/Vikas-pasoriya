import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Firebase को कनेक्ट करें
    await Firebase.initializeApp();
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
        scaffoldBackgroundColor: const Color(0xFFFFF8E1), // हल्का क्रीम कलर
        textTheme: GoogleFonts.hindTextTheme(), // हिंदी फोंट्स के लिए
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
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // थारे डेटाबेस में 'menus' नाम का कलेक्शन सै
        stream: FirebaseFirestore.instance.collection('menus').snapshots(),
        builder: (context, snapshot) {
          
          // डिफ़ॉल्ट डेटा (अगर नेट ना हो या डेटाबेस खाली हो तो यो दिखेगा)
          String mainTitle = "हरि ॐ जी!";
          String description = "टीम विकास पासोरिया";
          String ytUrl = "https://youtube.com/@VikasPasoriya";

          // अगर डेटाबेस तै डेटा मिल गया
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            var doc = snapshot.data!.docs.first.data() as Map<String, dynamic>;
            mainTitle = doc['title'] ?? mainTitle;
            description = doc['desc'] ?? description;
            // अगर यूट्यूब लिंक भी डेटाबेस में डालोगे तो यहाँ से अपडेट होगा
            ytUrl = doc['youtube'] ?? ytUrl;
          }

          // सफ़ेद स्क्रीन का झंझट खत्म - सीधा डिज़ाइन दिखाओ
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),
                // थारा किला वाला आइकॉन
                const Icon(Icons.fort_rounded, size: 120, color: Colors.deepOrange),
                const SizedBox(height: 20),
                
                Text(mainTitle, 
                  style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                
                const SizedBox(height: 25),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(description, 
                    textAlign: TextAlign.center, 
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black87)),
                ),

                const SizedBox(height: 50),

                // सहयोग राशि (UPI) बटन
                _buildActionButton(
                  context,
                  label: 'सहयोग राशि दें',
                  icon: Icons.volunteer_activism,
                  color: Colors.deepOrange,
                  onTap: () => _payUPI("your-upi@okicici"), // अपनी UPI ID यहाँ डालें
                ),

                const SizedBox(height: 20),

                // यूट्यूब बटन
                _buildActionButton(
                  context,
                  label: 'यूट्यूब चैनल देखें',
                  icon: Icons.video_library,
                  color: Colors.red,
                  onTap: () => _launchURL(ytUrl),
                ),
                
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  // बटन बनाने का सुंदर डिज़ाइन
  Widget _buildActionButton(BuildContext context, {required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 15),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // यूआरएल खोलने के लिए
  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  // पेमेंट के लिए
  _payUPI(String upi) async {
    final url = "upi://pay?pa=$upi&pn=Vikas&cu=INR";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
