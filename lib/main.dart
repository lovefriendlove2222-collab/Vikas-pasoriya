import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: VikasHeavyApp()));
}

class VikasHeavyApp extends StatelessWidget {
  const VikasHeavyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: FadeInDown(child: const Text('विकास पासोरिया ऑफिशियल')),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // भारी ब्रांडिंग सेक्शन
            ZoomIn(
              child: const Icon(Icons.music_video, size: 120, color: Colors.deepOrange),
            ),
            const SizedBox(height: 40),
            // यूट्यूब बटन
            FadeInLeft(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 65),
                  ),
                  onPressed: () => launchUrl(Uri.parse("https://youtube.com/@vikaspasoriya")),
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text("YOUTUBE CHANNEL", style: TextStyle(fontSize: 22, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
