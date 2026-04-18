import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Firebase शुरू करें
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase Error: $e");
  }
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // क्रीम कलर
      appBar: AppBar(
        title: const Text('विकास पासोरिया ऑफिसियल'),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        // यहाँ वही स्पेलिंग है जो आपके Firebase में है
        stream: FirebaseFirestore.instance.collection('settilng').doc('app_config').snapshots(),
        builder: (context, snapshot) {
          
          // डिफ़ॉल्ट डेटा (अगर नेट न हो या Firebase में डेटा न मिले)
          String yt = "https://youtube.com/@VikasPasoriya";
          String upi = "paytmqr123@paytm";
          String info = "पंडित विकास पासोरिया सांस्कृतिक एवं आध्यात्मिक पाठशाला";

          // अगर डेटा मिल गया तो उसे अपडेट करें
          if (snapshot.hasData && snapshot.data!.exists) {
            var d = snapshot.data!.data() as Map<String, dynamic>;
            yt = d['youtube'] ?? yt;
            upi = d['upi'] ?? upi;
            info = d['about'] ?? info;
          }

          // सफ़ेद स्क्रीन से बचने के लिए सीधा UI रिटर्न करें
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),
                // आपका मुख्य आइकॉन
                const Icon(Icons.fort_rounded, size: 120, color: Colors.deepOrange),
                const SizedBox(height: 10),
                const Text('हरि ॐ जी!', 
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                
                const SizedBox(height: 40),
                
                // संस्था की जानकारी
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(info, 
                    textAlign: TextAlign.center, 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                ),

                const SizedBox(height: 50),

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

                const SizedBox(height: 20),

                // यूट्यूब बटन
                TextButton.icon(
                  onPressed: () => _launch(yt),
                  icon: const Icon(Icons.video_library, color: Colors.red),
                  label: const Text("यूट्यूब चैनल देखें", style: TextStyle(fontSize: 18, color: Colors.black)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // लिंक खोलने के लिए
  _launch(url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  // पेमेंट के लिए
  _pay(upi) async {
    final url = "upi://pay?pa=$upi&pn=Vikas&cu=INR";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
