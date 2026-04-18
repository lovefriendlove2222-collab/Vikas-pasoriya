import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  // १. ऐप शुरू होणे तै पहले जरूरी चेकिंग
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // २. Firebase के साथ कनेक्शन जोड़ना
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase Initialize Error: $e");
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
      // ३. बैकग्राउंड का रंग (हल्का संतरी)
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text('विकास पासोरिया ऑफिसियल'),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // ४. सीधा 'settings' कलेक्शन तै डेटा उठाणा
        stream: FirebaseFirestore.instance.collection('settings').snapshots(),
        builder: (context, snapshot) {
          
          // ५. जब तक डेटा आ रहा है (सफेद स्क्रीन नी दिखेगी, लोडिंग दिखेगी)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          }

          // ६. अगर कोई गड़बड़ हो ज्या (Error Handling)
          if (snapshot.hasError) {
            return Center(child: Text("नेटवर्क चैक करो भाई: ${snapshot.error}"));
          }

          // ७. जब डेटा मिल ज्या
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
            
            // डेटाबेस तै 'youtube' लिंक ठा लिया
            String youtubeUrl = data['youtube'] ?? "https://youtube.com/@VikasPasoriya";

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ऊपर म्यूजिक का लोगो
                  const Icon(Icons.music_video, size: 120, color: Colors.deepOrange),
                  const SizedBox(height: 30),
                  
                  // नाम और पहचान
                  const Text("विकास पासोरिया", 
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.brown)),
                  const SizedBox(height: 10),
                  const Text("हरियाणा की बुलंद आवाज़", 
                    style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: Colors.black54)),
                  
                  const SizedBox(height: 50),

                  // यूट्यूब वाला लाल बटन
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      elevation: 10,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () async {
                      final url = Uri.parse(youtubeUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.play_circle_filled, size: 30),
                    label: const Text("यूट्यूब चैनल देखें", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }

          // ८. अगर settings कलेक्शन खाली मिल्या
          return const Center(
            child: Text("भाई, Firebase में 'settings' नाम का डेटा कोनी मिल्या!"),
          );
        },
      ),
    );
  }
}
