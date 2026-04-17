import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
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
        useMaterial3: true,
        primarySwatch: Colors.orange,
        textTheme: GoogleFonts.hindTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // --- फंक्शन जो फीचर चालू करेंगे ---
  
  // यूट्यूब चैनल के लिए
  Future<void> _openYoutube() async {
    final Uri url = Uri.parse('https://www.youtube.com/@VikasPasoriya');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  // बुकिंग के लिए सीधा फ़ोन नंबर (अपना नंबर बदल लेना भाई)
  Future<void> _makeCall() async {
    final Uri url = Uri.parse('tel:+919999999999'); 
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  // इंस्टाग्राम के लिए
  Future<void> _openInsta() async {
    final Uri url = Uri.parse('https://www.instagram.com/vikas_pasoriya');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('विकास पासोरिया ऑफिशियल'),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
        elevation: 4,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.orangeAccent),
              accountName: Text('विकास पासोरिया', style: TextStyle(fontSize: 20)),
              accountEmail: Text('लोकगायक व कलाकार'),
              currentAccountPicture: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, size: 50)),
            ),
            ListTile(leading: const Icon(Icons.play_circle), title: const Text('यूट्यूब चैनल'), onTap: _openYoutube),
            ListTile(leading: const Icon(Icons.phone), title: const Text('बुकिंग संपर्क'), onTap: _makeCall),
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('इंस्टाग्राम'), onTap: _openInsta),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            _card('लाइव प्रोग्राम', Icons.live_tv, Colors.red, _openYoutube),
            _card('यूट्यूब चैनल', Icons.play_circle_fill, Colors.redAccent, _openYoutube),
            _card('गैलरी', Icons.photo_library, Colors.blue, () {}),
            _card('बुकिंग', Icons.phone_android, Colors.green, _makeCall),
            _card('इंस्टाग्राम', Icons.camera_alt, Colors.pink, _openInsta),
            _card('नयी रागनी', Icons.music_note, Colors.purple, _openYoutube),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, IconData icon, Color color, VoidCallback action) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: action,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
