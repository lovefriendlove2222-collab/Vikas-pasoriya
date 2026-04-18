import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { await Firebase.initializeApp().timeout(const Duration(seconds: 5)); } catch (e) {}
  runApp(const VikasApp());
}

class VikasApp extends StatelessWidget {
  const VikasApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepOrange, textTheme: GoogleFonts.hindTextTheme()),
      home: const HomeScreen(),
    );
  }
}

// ---------------- 1. होम स्क्रीन (Dynamic - एडमिन के कंट्रोल में) ----------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('settings').doc('app_config').snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
        // अगर डेटा नहीं है तो डिफ़ॉल्ट वैल्यू
        var data = snap.data;
        String ytLink = data?['youtube'] ?? "https://youtube.com/@VikasPasoriya";
        String aboutText = data?['about'] ?? "विकास पासोरिया ऑफिसियल जनसेवा हेतु समर्पित है।";

        return Scaffold(
          appBar: AppBar(
            title: const Text('विकास पासोरिया ऑफिसियल'),
            backgroundColor: Colors.deepOrange,
            actions: [
              IconButton(icon: const Icon(Icons.admin_panel_settings), 
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLoginPage())))
            ],
          ),
          body: SingleChildScrollView(
            child: Column(children: [
              const SizedBox(height: 30),
              const Icon(Icons.fort_rounded, size: 100, color: Colors.deepOrange),
              const Text('हरि ॐ जी!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
              const SizedBox(height: 30),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, minimumSize: const Size(double.infinity, 60)),
                  icon: const Icon(Icons.volunteer_activism, color: Colors.white),
                  label: const Text('डोनेशन दें', style: TextStyle(color: Colors.white, fontSize: 20)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DonationPage())),
                ),
              ),

              GridView.count(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2, padding: const EdgeInsets.all(20), mainAxisSpacing: 15, crossAxisSpacing: 15,
                children: [
                  _box(Icons.account_balance, "संस्था जानकारी", () => _msg(context, aboutText)),
                  _box(Icons.video_library, "यूट्यूब वीडियो", () => launchUrl(Uri.parse(ytLink))),
                  _box(Icons.music_note, "भजन संगीत", () => launchUrl(Uri.parse("$ytLink/videos"))),
                  _box(Icons.contact_support, "संपर्क", () => launchUrl(Uri.parse("tel:+91XXXXXXXXXX"))),
                ],
              ),
            ]),
          ),
        );
      }
    );
  }

  Widget _box(IconData icon, String title, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 40, color: Colors.deepOrange), Text(title)]),
    ),
  );

  _msg(context, txt) => showDialog(context: context, builder: (c) => AlertDialog(title: const Text("सूचना"), content: Text(txt)));
}

// ---------------- 2. एडमिन डैशबोर्ड (जहाँ से सब अपडेट होगा) ----------------
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _ytC = TextEditingController();
  final _upiC = TextEditingController();
  final _aboutC = TextEditingController();

  _updateConfig() async {
    await FirebaseFirestore.instance.collection('settings').doc('app_config').set({
      'youtube': _ytC.text,
      'upi': _upiC.text,
      'about': _aboutC.text,
    }, SetOptions(merge: true));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('जानकारी अपडेट हो गई!')));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('एडमिन कंट्रोल'),
          bottom: const TabBar(tabs: [Tab(text: "डोनेशन लिस्ट"), Tab(text: "जानकारी बदलें")]),
        ),
        body: TabBarView(children: [
          // Tab 1: डोनेशन लिस्ट
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('donations').orderBy('time', descending: true).snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              return ListView.builder(
                itemCount: snap.data!.docs.length,
                itemBuilder: (context, i) {
                  var d = snap.data!.docs[i];
                  return ListTile(title: Text("${d['name']} - ₹${d['amount']}"), subtitle: Text(d['mobile']), trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => d.reference.delete()));
                },
              );
            },
          ),
          // Tab 2: जानकारी अपडेट फॉर्म
          Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(children: [
              TextField(controller: _ytC, decoration: const InputDecoration(labelText: 'यूट्यूब चैनल लिंक')),
              TextField(controller: _upiC, decoration: const InputDecoration(labelText: 'UPI ID (Payment)')),
              TextField(controller: _aboutC, decoration: const InputDecoration(labelText: 'संस्था की जानकारी'), maxLines: 3),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _updateConfig, child: const Text('सब अपडेट करें'))
            ]),
          ),
        ]),
      ),
    );
  }
}

// बाकी DonationPage और AdminLoginPage पुराने कोड की ढाल ही रहेंगे।
class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    final pass = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('लॉगिन')),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        TextField(controller: pass, decoration: const InputDecoration(labelText: 'पासवर्ड'), obscureText: true),
        ElevatedButton(onPressed: () {
          if (pass.text == "vikas@bhagwa") Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
        }, child: const Text('लॉगिन'))
      ])),
    );
  }
}

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('विवरण भरें')), body: const Center(child: Text("यहाँ डोनेशन फॉर्म आएगा")));
  }
}
