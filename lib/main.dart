import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 5));
  } catch (e) { print("Firebase Error: $e"); }
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
        scaffoldBackgroundColor: const Color(0xFFFFF8E1),
        textTheme: GoogleFonts.hindTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // यूट्यूब या सोशल मीडिया खोलने के लिए फंक्शन
  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('विकास पासोरिया ऑफिसियल'),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLoginPage())),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.fort_rounded, size: 80, color: Colors.deepOrange),
            const Text('हरि ॐ जी!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            
            const SizedBox(height: 20),
            
            // --- सारे मेनू ऑप्शन यहाँ हैं ---
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              padding: const EdgeInsets.all(15),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _menuItem(context, Icons.volunteer_activism, "डोनेशन / सहयोग", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DonationPage()))),
                _menuItem(context, Icons.account_balance, "संस्था की जानकारी", () => _showAbout(context)),
                _menuItem(context, Icons.qr_code_2, "UPI / QR कोड", () => _showQR(context)),
                _menuItem(context, Icons.music_note, "भजन संगीत", () => _launchURL("https://www.youtube.com/@VikasPasoriya/videos")),
                _menuItem(context, Icons.video_library, "यूट्यूब वीडियो", () => _launchURL("https://www.youtube.com/@VikasPasoriya")),
                _menuItem(context, Icons.badge, "डिजिटल ID कार्ड", () => _showIDMsg(context)),
                _menuItem(context, Icons.receipt, "रसीद सिस्टम", () => _showReceiptMsg(context)),
                _menuItem(context, Icons.contact_phone, "संपर्क करें", () => _launchURL("tel:+9198XXXXXXXX")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // मेनू बटन का डिज़ाइन
  Widget _menuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.deepOrange.withOpacity(0.3))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.deepOrange),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // --- अलग-अलग फीचर्स के पॉप-अप ---
  _showQR(context) {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("सहयोग हेतु QR कोड"),
      content: Image.network("https://upload.wikimedia.org/wikipedia/commons/d/d0/QR_code_for_mobile_English_Wikipedia.svg"), // यहाँ अपना QR फोटो लिंक डालना
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("बंद करें"))],
    ));
  }

  _showAbout(context) {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("संस्था के बारे में"),
      content: const Text("विकास पासोरिया ऑफिसियल संस्था जन सेवा और धर्म प्रचार के कार्यों में समर्पित है।"),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("ठीक है"))],
    ));
  }

  _showIDMsg(context) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ID कार्ड डोनेशन के बाद एडमिन द्वारा जारी किया जाएगा।")));
  _showReceiptMsg(context) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("डिजिटल रसीद आपके व्हाट्सएप पर भेज दी जाएगी।")));
}

// ---------------- 2. डोनेशन विवरण पेज ----------------
class DonationPage extends StatefulWidget {
  const DonationPage({super.key});
  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _village = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _amount = TextEditingController();
  bool _loading = false;

  _save() async {
    if (_name.text.isEmpty || _mobile.text.isEmpty || _amount.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया पूरी जानकारी भरें!')));
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('donations').add({
        'name': _name.text, 'mobile': _mobile.text, 'village': _village.text,
        'city': _city.text, 'state': _state.text, 'amount': _amount.text, 'time': DateTime.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('विवरण सुरक्षित सेव हो गया!')));
      Navigator.pop(context);
    } catch (e) { print(e); }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('सहयोग विवरण दर्ज करें')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'नाम *')),
            TextField(controller: _mobile, decoration: const InputDecoration(labelText: 'मोबाइल नम्बर *'), keyboardType: TextInputType.phone),
            TextField(controller: _village, decoration: const InputDecoration(labelText: 'गाँव')),
            TextField(controller: _city, decoration: const InputDecoration(labelText: 'शहर')),
            TextField(controller: _state, decoration: const InputDecoration(labelText: 'राज्य')),
            TextField(controller: _amount, decoration: const InputDecoration(labelText: 'राशि (₹) *'), keyboardType: TextInputType.number),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _save, child: const Text('सेव करें और आगे बढ़ें')),
          ],
        ),
      ),
    );
  }
}

// ---------------- 3. एडमिन पैनल ----------------
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});
  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _pass = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('एडमिन लॉगिन')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          TextField(controller: _pass, decoration: const InputDecoration(labelText: 'पासवर्ड दर्ज करें'), obscureText: true),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () {
            if (_pass.text == "vikas@bhagwa") {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('गलत पासवर्ड!')));
            }
          }, child: const Text('लॉगिन करें'))
        ]),
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('डोनेशन डेटा लिस्ट')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('donations').orderBy('time', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, i) {
              var d = snap.data!.docs[i];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text("${d['name']} - ₹${d['amount']}"),
                  subtitle: Text("${d['mobile']}\n${d['village']}, ${d['city']}"),
                  trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => d.reference.delete()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
