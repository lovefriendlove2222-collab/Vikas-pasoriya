import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Firebase को सिर्फ 3 सेकंड दिए, वरना ऐप आगे बढ़ जाएगा
    await Firebase.initializeApp().timeout(const Duration(seconds: 3));
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
        scaffoldBackgroundColor: const Color(0xFFFFF8E1),
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
      // FutureBuilder का इस्तेमाल किया ताकि डेटा न मिलने पे भी ऐप चले
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('settings').doc('app_config').snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
          // कति डिफ़ॉल्ट डेटा - जो हमेशा दिखेगा
          String yt = "https://youtube.com/@VikasPasoriya";
          String upi = "paytmqr123@paytm"; // यहाँ अपनी असली ID डालना
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange, 
                    minimumSize: const Size(double.infinity, 65),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                  ),
                  icon: const Icon(Icons.volunteer_activism, color: Colors.white, size: 30),
                  label: const Text('सहयोग राशि / डोनेशन दें', style: TextStyle(color: Colors.white, fontSize: 20)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DonationPage(upiID: upi))),
                ),
              ),

              const SizedBox(height: 20),

              GridView.count(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2, padding: const EdgeInsets.all(20), mainAxisSpacing: 15, crossAxisSpacing: 15,
                children: [
                  _btn(Icons.account_balance, "संस्था जानकारी", () => _showPop(context, info)),
                  _btn(Icons.video_library, "यूट्यूब वीडियो", () => _launch(yt)),
                  _btn(Icons.music_note, "भजन संगीत", () => _launch("$yt/videos")),
                  _btn(Icons.contact_support, "संपर्क करें", () => _launch("tel:+9198XXXXXXXX")),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.deepOrange.withOpacity(0.2))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(i, size: 45, color: Colors.deepOrange),
        const SizedBox(height: 8),
        Text(t, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      ]),
    ),
  );

  _launch(u) async { if (await canLaunchUrl(Uri.parse(u))) await launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication); }
  _showPop(context, txt) => showDialog(context: context, builder: (c) => AlertDialog(content: Text(txt), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("OK"))]));
}

// ---------------- 2. डोनेशन विवरण + यूपीआई पेमेंट ----------------
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
      body: _load ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          TextField(controller: _n, decoration: const InputDecoration(labelText: 'आपका नाम *')),
          const SizedBox(height: 10),
          TextField(controller: _m, decoration: const InputDecoration(labelText: 'मोबाइल नम्बर'), keyboardType: TextInputType.phone),
          const SizedBox(height: 10),
          TextField(controller: _a, decoration: const InputDecoration(labelText: 'सहयोग राशि (₹) *'), keyboardType: TextInputType.number),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.green),
            onPressed: () async {
              if (_n.text.isEmpty || _a.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("नाम और राशि भरें!")));
                return;
              }
              setState(() => _load = true);
              try {
                await FirebaseFirestore.instance.collection('donations').add({
                  'name': _n.text, 'mobile': _m.text, 'amount': _a.text, 'time': DateTime.now()
                });
                final url = "upi://pay?pa=${widget.upiID}&pn=Vikas&am=${_a.text}&cu=INR";
                await launchUrl(Uri.parse(url));
                Navigator.pop(context);
              } catch (e) { print(e); }
              setState(() => _load = false);
            },
            child: const Text('डिटेल्स सेव करें और पेमेंट करें', style: TextStyle(color: Colors.white)),
          )
        ]),
      ),
    );
  }
}

// ---------------- 3. एडमिन पैनल (Settings & List) ----------------
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
        appBar: AppBar(title: const Text('एडमिन कंट्रोल'), bottom: const TabBar(tabs: [Tab(text: "डोनेशन लिस्ट"), Tab(text: "सेटिंग्स")])),
        body: TabBarView(children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('donations').orderBy('time', descending: true).snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              return ListView.builder(itemCount: snap.data!.docs.length, itemBuilder: (context, i) {
                var d = snap.data!.docs[i];
                return Card(child: ListTile(title: Text("${d['name']} - ₹${d['amount']}"), subtitle: Text(d['mobile']), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => d.reference.delete())));
              });
            },
          ),
          Padding(padding: const EdgeInsets.all(20), child: ListView(children: [
            TextField(controller: _yt, decoration: const InputDecoration(labelText: 'YouTube Link')),
            TextField(controller: _up, decoration: const InputDecoration(labelText: 'UPI ID')),
            TextField(controller: _ab, decoration: const InputDecoration(labelText: 'About Info')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () async {
              await FirebaseFirestore.instance.collection('settings').doc('app_config').set({'youtube': _yt.text, 'upi': _up.text, 'about': _ab.text}, SetOptions(merge: true));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated!')));
            }, child: const Text('Update Settings'))
          ])),
        ]),
      ),
    );
  }
}
