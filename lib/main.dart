import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MaterialApp(home: VikasBadshahApp(), debugShowCheckedModeBanner: false));

class VikasBadshahApp extends StatelessWidget {
  const VikasBadshahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("बादशाह DJ साउंड - विवेक"), backgroundColor: Colors.orange),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("राम-राम! मैं हूँ लोकगायक विवेक", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => launchUrl(Uri.parse("https://youtube.com/@vikas_pasoriya")),
              child: const Text("मेरे लाइव प्रोग्राम (YouTube सिंक)"),
            ),
            const SizedBox(height: 30),
            const Text("सहयोग QR (UPI)", style: TextStyle(fontWeight: FontWeight.bold)),
            // तेरा असली QR डेटा
            Image.network("https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=upi://pay?pa=7206966924vivek@axl"),
          ],
        ),
      ),
    );
  }
}
