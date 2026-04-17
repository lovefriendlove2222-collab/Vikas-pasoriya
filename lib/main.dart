import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        useMaterial: true,
        textTheme: GoogleFonts.hindTextTheme(), // हरियाणवी/हिंदी फोंट के लिए
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      app_bar: AppBar(
        title: const Text('विकास पासोरिया ऑफिशियल'),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
      ),
      // --- यहाँ से साइड मेन्यू (Options) शुरू होता है ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.orangeAccent),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Icon(Icons.person, size: 50)),
                  S_box(height: 10),
                  Text('राम-राम जी!', style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('होम'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('मेरे प्रोग्राम (Videos)'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text('नए रागनी / गाने'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.contact_phone),
              title: const Text('संपर्क करें'),
              onTap: () {},
            ),
          ],
        ),
      ),
      // --- होम स्क्रीन के बटन ---
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildMenuCard('लाइव प्रोग्राम', Icons.live_tv, Colors.red),
            _buildMenuCard('गैलरी', Icons.photo_library, Colors.blue),
            _buildMenuCard('यूट्यूब चैनल', Icons.play_circle_fill, Colors.redAccent),
            _buildMenuCard('बुकिंग', Icons.event, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(String title, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const S_box(height: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// छोटी सी हेल्पर क्लास
class S_box extends StatelessWidget {
  final double height;
  const S_box({super.key, required this.height});
  @override
  Widget build(BuildContext context) { return SizedBox(height: height); }
}
