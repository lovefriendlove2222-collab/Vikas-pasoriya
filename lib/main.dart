import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(VikasOfficialApp());

class VikasOfficialApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vikas Pasoriya Official',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Color(0xFFFFFAF0), // भगवा आभा
        textTheme: GoogleFonts.hindTextTheme(),
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3 सेकंड बाद लॉगिन या रजिस्ट्रेशन पेज पर ले जाएगा
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("🙏 हरि ॐ जी 🙏", style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text("स्वागत है विकास पासोरिया\nऑफिसियल एप में", 
                 textAlign: TextAlign.center,
                 style: TextStyle(fontSize: 22, color: Colors.white70)),
            SizedBox(height: 40),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("विकास पासोरिया ऑफिसियल"), backgroundColor: Colors.orange[800]),
      body: Center(child: Text("यहाँ आपका डैशबोर्ड और फीचर्स आएंगे")),
    );
  }
}
