import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("शुरुआत में ही गड़बड़ सै: $e");
  }
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DebugScreen(),
  ));
}

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firebase चेकिंग..."), backgroundColor: Colors.red),
      body: StreamBuilder<QuerySnapshot>(
        // थारे कलेक्शन का नाम 'menus' सै
        stream: FirebaseFirestore.instance.collection('menus').snapshots(),
        builder: (context, snapshot) {
          
          // १. अगर अभी इंतज़ार हो रह्या सै
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("डेटाबेस तै हाथ मिलाण की कोशिश जारी सै..."),
                ],
              ),
            );
          }

          // २. अगर एरर आया—यही सबसे ज़रूरी हिस्सा सै!
          if (snapshot.hasError) {
            return Container(
              color: Colors.yellow[100],
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 50),
                    const SizedBox(height: 20),
                    const Text("गड़बड़ मिल गई भाई!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    // यो मैसेज थारी स्क्रीन पै दिखेगा, इसकी फोटो भेज दियो
                    Text("${snapshot.error}", 
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // ३. अगर डेटा मिल गया
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 60),
                  const SizedBox(height: 20),
                  const Text("बधाई हो! डेटा मिल गया!", style: TextStyle(fontSize: 22, color: Colors.green)),
                  const SizedBox(height: 20),
                  Text("कुल आइटम्स: ${snapshot.data!.docs.length}"),
                ],
              ),
            );
          }

          // ४. अगर डेटाबेस खाली सै
          return const Center(child: Text("डेटाबेस में कुछ नी मिल्या, कति खाली सै!"));
        },
      ),
    );
  }
}
