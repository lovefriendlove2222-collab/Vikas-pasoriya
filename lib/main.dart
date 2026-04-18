import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase Setup Error: $e");
  }
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

// ---------------- 1. होम स्क्रीन (Dynamic Control) ----------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('settings').doc('app_config').snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
        // अगर डेटा लोड हो रहा या नहीं मिला, तो ये डिफॉल्ट वैल्यू काम करेंगी
        String ytLink = "https://youtube.com/@VikasPasoriya";
        String aboutText = "विकास पासोरिया ऑफिसियल जनसेवा हेतु समर्पित है।";
        
        if (snap.hasData && snap.data!.exists) {
          var d = snap.data!;
          ytLink = d['youtube'] ?? ytLink;
          aboutText = d['about'] ?? aboutText;
        }

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
                  label: const Text('सहयोग राशि / डोनेशन दें', style: TextStyle(color: Colors.white, fontSize: 20)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DonationPage())),
                ),
              ),

              GridView.count(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2, padding: const EdgeInsets.all(20), mainAxisSpacing: 15, crossAxisSpacing: 15,
                children: [
                  _box(Icons.account_balance, "संस्था जानकारी", () => _msg(context, aboutText)),
                  _box(Icons.video_library, "यूट्यूब वीडियो", () => _launch(ytLink)),
                  _box(Icons.music_note, "भजन संगीत", () => _launch("$ytLink/videos")),
                  _box(Icons.contact_support, "संपर्क करें", () => _launch("tel:+91XXXXXXXXXX")),
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
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 40, color: Colors.deepOrange), const SizedBox(height: 10), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))]),
    ),
  );

  _launch(url) async { if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); }
  _msg(context, txt) => showDialog(context: context, builder: (c) => AlertDialog(title: const Text("सूचना"), content: Text(txt), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("ठीक है"))]));
}

// ---------------- 2. डोनेशन + पेमेंट (पहले डिटेल, फिर पेमेंट) ----------------
class DonationPage extends StatefulWidget {
  const DonationPage({super.key});
  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _amount = TextEditingController();
  final _village = TextEditingController();
  bool _loading = false;

  _pay() async {
    if (_name.text.isEmpty || _mobile.text.isEmpty || _amount.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('पूरी जानकारी भरें!')));
      return;
    }
    setState(() => _loading = true);
    try {
      // डेटा सेव करें
      await FirebaseFirestore.instance.collection('donations').add({
        'name': _name.text, 'mobile': _mobile.text, 'village': _village.text,
        'amount': _amount.text, 'time': DateTime.now()
      });
      // पेमेंट लिंक खोलें
      var snap = await FirebaseFirestore.instance.collection('settings').doc('app_config').get();
      String upi = snap.exists ? snap['upi'] : "YOUR_UPI@okicici";
      final url = "upi://pay?pa=$upi&pn=VikasPasoriya&am=${_amount.text}&cu=INR";
      await launchUrl(Uri.parse(url));
      Navigator.pop(context);
    } catch (e) { print(e); }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('सहयोग विवरण')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'नाम *')),
          TextField(controller: _mobile, decoration: const InputDecoration(labelText: 'मोबाइल *'), keyboardType: TextInputType.phone),
          TextField(controller: _village, decoration: const InputDecoration(labelText: 'गाँव/शहर')),
          TextField(controller: _amount, decoration: const InputDecoration(labelText: 'राशि (₹) *'), keyboardType: TextInputType.number),
          const SizedBox(height: 30),
          ElevatedButton(onPressed: _pay, style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)), child: const Text('सेव करें और पेमेंट करें')),
        ]),
      ),
    );
  }
}

// ---------------- 3. एडमिन पैनल (जहाँ से सब अपडेट होगा) ----------------
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _ytC = TextEditingController();
  final _upiC = TextEditingController();
  final _aboutC = TextEditingController();

  _saveSettings() async {
    await FirebaseFirestore.instance.collection('settings').doc('app_config').set({
      'youtube': _ytC.text, 'upi': _upiC.text, 'about': _aboutC.text,
    }, SetOptions(merge: true));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('सिस्टम अपडेट हो गया!')));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: const Text('एडमिन कंट्रोल'), bottom: const TabBar(tabs: [Tab(text: "डोनेशन"), Tab(text: "सेटिंग्स")])),
        body: TabBarView(children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('donations').orderBy('time', descending: true).snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              return ListView.builder(itemCount: snap.data!.docs.length, itemBuilder: (context, i) {
                var d = snap.data!.docs[i];
                return ListTile(title: Text("${d['name']} - ₹${d['amount']}"), subtitle: Text(d['mobile']), trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => d.reference.delete()));
              });
            },
          ),
          Padding(padding: const EdgeInsets.all(20), child: ListView(children: [
            TextField(controller: _ytC, decoration: const InputDecoration(labelText: 'नया यूट्यूब लिंक')),
            TextField(controller: _upiC, decoration: const InputDecoration(labelText: 'नया UPI ID (Payment)')),
            TextField(controller: _aboutC, decoration: const InputDecoration(labelText: 'संस्था जानकारी'), maxLines: 3),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveSettings, child: const Text('सारी जानकारी अपडेट करें'))
          ])),
        ]),
      ),
    );
  }
}

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    final pass = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('एडमिन लॉगिन')),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        TextField(controller: pass, decoration: const InputDecoration(labelText: 'पासवर्ड'), obscureText: true),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () { if (pass.text == "vikas@bhagwa") Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard())); }, child: const Text('लॉगिन'))
      ])),
    );
  }
}
