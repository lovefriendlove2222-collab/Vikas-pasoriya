import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Firebase को 5 सेकंड का टाइमआउट दिया ताकि ऐप सफ़ेद स्क्रीन पे न फंसे
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
        scaffoldBackgroundColor: const Color(0xFFFFF8E1), // लाइट क्रीम बैकग्राउंड
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
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLoginPage())),
          )
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('settings').doc('app_config').snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
          // डिफ़ॉल्ट डेटा (अगर इंटरनेट न हो या Firebase न चले)
          String yt = "https://youtube.com/@VikasPasoriya";
          String upi = "your-upi@id";
          String info = "विकास पासोरिया ऑफिसियल जनसेवा हेतु समर्पित है।";

          if (snap.hasData && snap.data!.exists) {
            var d = snap.data!;
            yt = d['youtube'] ?? yt;
            upi = d['upi'] ?? upi;
            info = d['about'] ?? info;
          }

          return SingleChildScrollView(
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
                  label: const Text('डोनेशन दें (विवरण भरें)', style: TextStyle(color: Colors.white, fontSize: 18)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DonationPage(upiID: upi))),
                ),
              ),

              GridView.count(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2, padding: const EdgeInsets.all(20), mainAxisSpacing: 15, crossAxisSpacing: 15,
                children: [
                  _btn(Icons.account_balance, "संस्था जानकारी", () => _showPop(context, info)),
                  _btn(Icons.video_library, "यूट्यूब वीडियो", () => _launch(yt)),
                  _btn(Icons.music_note, "भजन संगीत", () => _launch("$yt/videos")),
                  _btn(Icons.contact_support, "संपर्क करें", () => _launch("tel:+91XXXXXXXXXX")),
                ],
              ),
            ]),
          );
        },
      ),
    );
  }

  Widget _btn(IconData i, String t, VoidCallback a) => InkWell(
    onTap: a,
    child: Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 40, color: Colors.deepOrange), Text(t, style: const TextStyle(fontWeight: FontWeight.bold))]),
    ),
  );

  _launch(u) async { if (await canLaunchUrl(Uri.parse(u))) await launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication); }
  _showPop(context, txt) => showDialog(context: context, builder: (c) => AlertDialog(content: Text(txt), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("OK"))]));
}

// ---------------- 2. डोनेशन और पेमेंट ----------------
class DonationPage extends StatefulWidget {
  final String upiID;
  const DonationPage({super.key, required this.upiID});
  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final _n = TextEditingController();
  final _m = TextEditingController();
  final _a = TextEditingController();
  bool _load = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('सहयोग विवरण')),
      body: _load ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          TextField(controller: _n, decoration: const InputDecoration(labelText: 'नाम')),
          TextField(controller: _m, decoration: const InputDecoration(labelText: 'मोबाइल'), keyboardType: TextInputType.phone),
          TextField(controller: _a, decoration: const InputDecoration(labelText: 'राशि (₹)'), keyboardType: TextInputType.number),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              if (_n.text.isEmpty || _a.text.isEmpty) return;
              setState(() => _load = true);
              await FirebaseFirestore.instance.collection('donations').add({'name': _n.text, 'mobile': _m.text, 'amount': _a.text, 'time': DateTime.now()});
              final url = "upi://pay?pa=${widget.upiID}&pn=Vikas&am=${_a.text}&cu=INR";
              await launchUrl(Uri.parse(url));
              Navigator.pop(context);
            },
            child: const Text('विवरण सेव करें और पेमेंट करें'),
          )
        ]),
      ),
    );
  }
}

// ---------------- 3. एडमिन पैनल ----------------
class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    final pass = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('एडमिन लॉगिन')),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        TextField(controller: pass, decoration: const InputDecoration(labelText: 'पासवर्ड'), obscureText: true),
        ElevatedButton(onPressed: () { if (pass.text == "vikas@bhagwa") Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard())); }, child: const Text('लॉगिन'))
      ])),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _yt = TextEditingController();
  final _up = TextEditingController();
  final _ab = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: const Text('एडमिन कंट्रोल'), bottom: const TabBar(tabs: [Tab(text: "Data"), Tab(text: "Settings")])),
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
            TextField(controller: _yt, decoration: const InputDecoration(labelText: 'यूट्यूब लिंक')),
            TextField(controller: _up, decoration: const InputDecoration(labelText: 'UPI ID')),
            TextField(controller: _ab, decoration: const InputDecoration(labelText: 'संस्था जानकारी')),
            ElevatedButton(onPressed: () async {
              await FirebaseFirestore.instance.collection('settings').doc('app_config').set({'youtube': _yt.text, 'upi': _up.text, 'about': _ab.text}, SetOptions(merge: true));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated!')));
            }, child: const Text('अपडेट करें'))
          ])),
        ]),
      ),
    );
  }
}
