import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MaterialApp(
    home: VikasApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class VikasApp extends StatelessWidget {
  const VikasApp({super.key});

  // यूट्यूब चैनल खोलने का फंक्शन
  void _openYouTube() async {
    const url = 'https://youtube.com/@vikas_pasoriya'; // थारा चैनल
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("बादशाह DJ साउंड - विवेक"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text("राम-राम जी! मैं हूँ लोकगायक विवेक", 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // डेटा सिंक बटन
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text("मेरे लाइव प्रोग्राम (YouTube सिंक)"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: _openYouTube,
            ),
            
            const Divider(height: 40),
            const Text("सहयोग राशि (Online QR)", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            
            // तेरा UPI QR जो सीधा डेटा उठावेगा
            Image.network(
              "https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=upi://pay?pa=7206966924vivek@axl&pn=Vikas",
              height: 250,
            ),
            
            const SizedBox(height: 20),
            const Text("बाढड़ा (भिवानी) हरियाणा", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
