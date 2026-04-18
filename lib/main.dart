import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// इस बार हम Firebase का इंतज़ार ही नहीं करेंगे ताकि ऐप सफ़ेद न रहे
void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        scaffoldBackgroundColor: const Color(0xFFFFF8E1), // क्रीम कलर
        textTheme: GoogleFonts.hindTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // थारे पक्के लिंक - इन्हें तू यहाँ से बदल सकै सै
  final String ytLink = "https://youtube.com/@VikasPasoriya";
  final String upiID = "paytmqr123@paytm"; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('विकास पासोरिया ऑफिसियल'),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          const SizedBox(height: 40),
          // थारा किला वाला आइकॉन
          const Icon(Icons.fort_rounded, size: 120, color: Colors.deepOrange),
          const SizedBox(height: 10),
          const Text('हरि ॐ जी!', 
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
          const SizedBox(height: 40),
          
          // डोनेशन बटन
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange, 
                minimumSize: const Size(double.infinity, 70),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35))
              ),
              icon: const Icon(Icons.volunteer_activism, color: Colors.white, size: 30),
              label: const Text('सहयोग राशि / डोनेशन दें', 
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              onPressed: () => _payNow(context),
            ),
          ),

          const SizedBox(height: 30),

          // चार मुख्य बटन
          GridView.count(
            shrinkWrap: true, 
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, 
            padding: const EdgeInsets.all(25), 
            mainAxisSpacing: 20, 
            crossAxisSpacing: 20,
            children: [
              _menuBtn(Icons.account_balance, "संस्था जानकारी", () => _info(context)),
              _menuBtn(Icons.video_library, "यूट्यूब चैनल", () => _launch(ytLink)),
              _menuBtn(Icons.music_note, "भजन डायरी", () => _launch("$ytLink/videos")),
              _menuBtn(Icons.contact_support, "संपर्क करें", () => _launch("tel:+9198XXXXXXXX")),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _menuBtn(IconData icon, String label, VoidCallback tap) => InkWell(
    onTap: tap,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 50, color: Colors.deepOrange),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ]),
    ),
  );

  // पेमेंट का सीधा तरीका
  _payNow(context) async {
    final url = "upi://pay?pa=$upiID&pn=VikasPasoriya&cu=INR";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("कोई UPI ऐप नहीं मिला!")));
    }
  }

  _launch(url) async { if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); }
  
  _info(context) => showDialog(context: context, builder: (c) => AlertDialog(
    title: const Text("संस्था जानकारी"),
    content: const Text("विकास पासोरिया ऑफिसियल जनसेवा और हरियाणवी संस्कृति के उत्थान हेतु समर्पित है।"),
    actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("ठीक है"))]
  ));
}
