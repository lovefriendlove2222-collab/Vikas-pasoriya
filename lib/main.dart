import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'donation_page.dart';
import 'admin_panel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // 5 सेकंड का टाइमआउट ताकि ऐप अटके ना
    await Firebase.initializeApp().timeout(const Duration(seconds: 5));
  } catch (e) {
    print("Firebase Error: $e");
  }
  runApp(const VikasApp());
}

class VikasApp extends StatelessWidget {
  const VikasApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: const Color(0xFFFFF8E1), // भगवा थीम (image_1.png)
        textTheme: GoogleFonts.hindTextTheme(),
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
      appBar: AppBar(
        title: const Text('विकास पासोरिया ऑफिसियल'),
        backgroundColor: Colors.deepOrange,
        actions: [
          // एडमिन लॉगिन का छोटा बटन
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLoginPage())),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fort_rounded, size: 120, color: Colors.deepOrange),
            const SizedBox(height: 20),
            const Text('हरि ॐ जी!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              icon: const Icon(Icons.volunteer_activism, color: Colors.white),
              label: const Text('सहयोग राशि / डोनेशन दें', style: TextStyle(color: Colors.white, fontSize: 18)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DonationPage())),
            ),
          ],
        ),
      ),
    );
  }
}
