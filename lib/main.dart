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
            const SizedBox(height: 30),
            const Icon(Icons.fort_rounded, size: 100, color: Colors.deepOrange),
            const Text('हरि ॐ जी!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            const SizedBox(height: 30),
            
            // --- मुख्य बटन (डोनेशन और पेमेंट एक साथ) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                icon: const Icon(Icons.volunteer_activism, color: Colors.white),
                label: const Text('सहयोग राशि / डोनेशन दें', style: TextStyle(color: Colors.white, fontSize: 20)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DonationPage())),
              ),
            ),

            const SizedBox(height: 20),

            // --- बाकी ऑप्शन ---
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              padding: const EdgeInsets.all(20),
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              children: [
                _menuBox(Icons.account_balance, "संस्था की जानकारी", () => _showAbout(context)),
                _menuBox(Icons.qr_code_scanner, "UPI / QR कोड", () => _showQR(context)),
                _menuBox(Icons.music_note, "भजन संगीत", () => _launchURL("https://www.youtube.com/@VikasPasoriya/videos")),
                _menuBox(Icons.video_library, "यूट्यूब वीडियो", () => _launchURL("https://www.youtube.com/@VikasPasoriya")),
                _menuBox(Icons.receipt_long, "रसीद देखें", () => _showReceiptMsg(context)),
                _menuBox(Icons.contact_support, "संपर्क करें", () => _launchURL("tel:+9198XXXXXXXX")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuBox(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 45, color: Colors.deepOrange),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  _showQR(context) => showDialog(context: context, builder: (c) => AlertDialog(
    title: const Text("सहयोग हेतु QR"),
    content: Image.network("https://your-qr-link.com/qr.png"), // यहाँ अपना QR लिंक डालिये
    actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("बंद करें"))],
  ));

  _showAbout(context) => showDialog(context: context, builder: (c) => AlertDialog(
    title: const Text("संस्था"), content: const Text("विकास पासोरिया ऑफिसियल जनसेवा हेतु समर्पित है।"),
    actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("ठीक है"))],
  ));

  _showReceiptMsg(context) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("पेमेंट सफल होने के बाद एडमिन द्वारा रसीद भेजी जाएगी।")));
}

// ---------------- 2. डोनेशन + पेमेंट प्रोसेस ----------------
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

  _processPayment() async {
    if (_name.text.isEmpty || _mobile.text.isEmpty || _amount.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया जानकारी भरें!')));
      return;
    }
    setState(() => _loading = true);
    try {
      // 1. पहले डेटा सेव होगा
      await FirebaseFirestore.instance.collection('donations').add({
        'name': _name.text, 'mobile': _mobile.text, 'village': _village.text,
        'amount': _amount.text, 'time': DateTime.now(), 'status': 'Pending'
      });
      
      // 2. फिर पेमेंट लिंक खुलेगा (UPI Intent)
      final upiUrl = "upi://pay?pa=YOUR_UPI_ID@okicici&pn=VikasPasoriya&am=${_amount.text}&cu=INR"; 
      if (await canLaunchUrl(Uri.parse(upiUrl))) {
        await launchUrl(Uri.parse(upiUrl));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('पेमेंट सफल होने पर रसीद जारी होगी।')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('UPI ऐप नहीं मिला, कृपया QR कोड का उपयोग करें।')));
      }
    } catch (e) { print(e); }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('सहयोग विवरण')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'नाम *')),
          TextField(controller: _mobile, decoration: const InputDecoration(labelText: 'मोबाइल नम्बर *'), keyboardType: TextInputType.phone),
          TextField(controller: _village, decoration: const InputDecoration(labelText: 'गाँव/शहर')),
          TextField(controller: _amount, decoration: const InputDecoration(labelText: 'राशि (₹) *'), keyboardType: TextInputType.number),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
            onPressed: _processPayment, 
            child: const Text('विवरण सेव करें और पेमेंट करें', style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ]),
      ),
    );
  }
}

// ---------------- 3. एडमिन पैनल (कति वर्किंग) ----------------
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
          TextField(controller: _pass, decoration: const InputDecoration(labelText: 'पासवर्ड'), obscureText: true),
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
      appBar: AppBar(title: const Text('डोनेशन लिस्ट')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('donations').orderBy('time', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, i) {
              var d = snap.data!.docs[i];
              return Card(
                child: ListTile(
                  title: Text("${d['name']} - ₹${d['amount']}"),
                  subtitle: Text("${d['mobile']} | ${d['village']}"),
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
