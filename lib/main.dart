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
        useMaterial3: true,
        // कति भगवा रंग
        primarySwatch: Colors.deepOrange,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange, primary: Colors.deepOrange),
        textTheme: GoogleFonts.hindTextTheme(),
      ),
      home: const WelcomeScreen(),
    );
  }
}

// स्वागत स्क्रीन
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fort_rounded, size: 100, color: Colors.deepOrange),
              const SizedBox(height: 20),
              const Text(
                'हरि ॐ जी!',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.deepOrange),
              ),
              const Text(
                'स्वागत है विकास पासोरिया ऑफिसियल एप में',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
                onPressed: () {
                  // लॉगिन पेज पर भेजें
                },
                child: const Text('लॉगिन / रजिस्टर करें'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
