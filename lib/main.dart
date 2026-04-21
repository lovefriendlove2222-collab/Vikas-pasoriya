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
    const url = 'https://youtube.com/@vikas_pasoriya'; 
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("बादशाह DJ साउंड - विवेक"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.orange,
              child: Icon(Icons.music_note, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text("राम-राम जी! मैं हूँ लोकगायक विवेक", 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("बाढड़ा (हरियाणा)", style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 30),
            
            // डेटा सिंक बटन (YouTube)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_fill, size: 30),
                label: const Text("मेरे लाइव प्रोग्राम देखें", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                ),
                onPressed: _openYouTube,
              ),
            ),
            
            const Divider(height: 60, thickness: 2),
            const Text("सहयोग राशि (Online QR)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            // तेरा UPI QR जो सीधा डेटा उठावेगा
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 2)),
              child: Image.network(
                "https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=upi://pay?pa=7206966924vivek@axl&pn=Vikas",
                height: 250,
                width: 250,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
