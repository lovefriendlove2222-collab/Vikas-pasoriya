import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase Initialize यहाँ होवैगा
  runApp(const MaterialApp(home: VikasOfficialApp(), debugShowCheckedModeBanner: false));
}

class VikasOfficialApp extends StatelessWidget {
  const VikasOfficialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("बादशाह DJ साउंड - विवेक"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("राम-राम जी, मैं हूँ लोकगायक विवेक", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // ऑनलाइन सिंक बटन - सीधा YouTube चैनल पै
            ElevatedButton.icon(
              icon: const Icon(Icons.play_circle_fill),
              label: const Text("मेरे लाइव स्टेज प्रोग्राम देखें"),
              onPressed: () => launchUrl(Uri.parse("https://youtube.com/@vikas_pasoriya")),
            ),
            const Divider(height: 50),
            const Text("सहयोग राशि (UPI पेमेंट)", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            // थारा UPI जो तूने बताया था
            Image.network("https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=upi://pay?pa=7206966924vivek@axl"),
          ],
        ),
      ),
    );
  }
}
