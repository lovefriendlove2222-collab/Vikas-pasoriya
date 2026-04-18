import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Firebase को पूरी तरह लोड होने का इंतज़ार करें
    await Firebase.initializeApp();
    // Firestore की सेटिंग्स को "Persistence" मोड में डालें (ताकि ऑफलाइन भी चले)
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
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
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text('विकास पासोरिया ऑफिसियल'),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      // थारे Firebase का कलेक्शन 'menus'
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('menus').snapshots(),
        builder: (context, snapshot) {
          
          // १. अगर डेटा अभी लोड हो रहा है
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          }

          // २. अगर कोई एरर आ गया (यही बताएगा कि डेटाबेस क्यों नहीं मिल रहा)
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text("कनेक्शन एरर: ${snapshot.error}", textAlign: TextAlign.center),
              ),
            );
          }

          // ३. अगर डेटा मिल गया
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
                ],
              ),
            );
          }

          // ४. अगर डेटाबेस में कोई डॉक्यूमेंट ही नहीं है
          return const Center(child: Text("डेटाबेस खाली है भाई!"));
        },
      ),
    );
  }
}
