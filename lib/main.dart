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
      theme: ThemeData(primarySwatch: Colors.deepOrange, textTheme: GoogleFonts.hindTextTheme()),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fort_rounded, size: 100, color: Colors.deepOrange),
            const SizedBox(height: 20),
            const Text('हरि ॐ जी!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            const Text('स्वागत है विकास पासोरिया ऑफिसियल एप में', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UserList())),
              child: const Text('लॉगिन / रजिस्टर करें', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {}, // यहाँ एडमिन पैनल का रास्ता खुलेगा
              child: const Text('एडमिन लॉगिन', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}

// यूजर लिस्ट का डमी पेज (बाद में Firebase से जुड़ेगा)
class UserList extends StatelessWidget {
  const UserList({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('रजिस्टर्ड यूजर्स'), backgroundColor: Colors.deepOrange),
      body: const Center(child: Text('यहाँ यूजर की लिस्ट और डेटा दिखेगा')),
    );
  }
}
