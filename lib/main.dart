import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Firebase को कनेक्ट करने की कोशिश
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
      title: 'Vikas Pasoriya Official',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: const Color(0xFFFFF8E1), // थारी पसंद का क्रीम बैकग्राउंड
        textTheme: GoogleFonts.hindTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}

// ---------------- 1. होम स्क्रीन (सब कुछ यहीं से कंट्रोल होगा) ----------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('settings').doc('app_config').snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
        // डिफ़ॉल्ट डेटा (अगर नेट न हो तो ये चलेगा)
        String yt = "https://youtube.com/@VikasPasoriya";
        String upi = "your-upi@okicici"; // यहाँ अपनी UPI ID एडमिन पैनल से बदल लेना
        String info = "विकास पासोरिया ऑफिसियल जनसेवा और धर्म प्रचार हेतु समर्पित है।";

        if (snap.hasData && snap.data!.exists) {
          var d = snap.data!;
          yt = d['youtube'] ?? yt;
          upi = d['upi'] ?? upi;
          info = d['about'] ?? info;
        }

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
            child: Column(children: [
              const SizedBox(height: 30),
              const Icon(Icons.fort_rounded, size: 100, color: Colors.deepOrange),
              const Text('हरि ॐ जी!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
              const SizedBox(height: 30),
              
              // मुख्य डोनेशन बटन
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

              // बाकी चार बटन
              GridView.count(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2, padding: const EdgeInsets.all(20), mainAxisSpacing: 15, crossAxisSpacing: 15,
                children: [
                  _menuBtn(Icons.account_balance, "संस्था जानकारी", () => _showMsg(context, info)),
                  _menuBtn(Icons.video_library, "यूट्यूब वीडियो", () => _launchURL(yt)),
                  _menuBtn(Icons.music_note, "भजन डायरी", () => _launchURL("$yt/videos")),
                  _menuBtn(Icons.contact_support, "संपर्क करें", () => _launchURL("tel:+91XXXXXXXXXX")),
                ],
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _menuBtn(IconData i, String t, VoidCallback a) => InkWell(
    onTap: a,
    child: Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.deepOrange.withOpacity(0.2))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(i, size: 45, color: Colors.deepOrange),
        const SizedBox(height: 8),
        Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    ),
  );

  _launchURL(u) async { if (await canLaunchUrl(Uri.parse(u))) await launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication); }
  _showMsg(context, txt) => showDialog(context: context, builder: (c) => AlertDialog(content: Text(txt), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("OK"))]));
}

// ---------------- 2. डोनेशन पेज (डेटा सेव + पेमेंट) ----------------
class DonationPage extends StatefulWidget {
  final String upiID;
  const DonationPage({super.key, required this.upiID});
  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _amt = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('सहयोग विवरण')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'आपका नाम *')),
          TextField(controller: _phone, decoration: const InputDecoration(labelText: 'मोबाइल नम्बर'), keyboardType: TextInputType.phone),
          TextField(controller: _amt, decoration: const InputDecoration(labelText: 'सहयोग राशि (₹) *'), keyboardType: TextInputType.number),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.green),
            onPressed: () async {
              if (_name.text.isEmpty || _amt.text.isEmpty) return;
              setState(() => _loading = true);
              try {
                // पहले डेटाबेस में सेव
                await FirebaseFirestore.instance.collection('donations').add({
                  'name': _name.text, 'mobile': _phone.text, 'amount': _amt.text, 'time': DateTime.now()
                });
                // फिर पेमेंट ऐप खोलना
                final url = "upi://pay?pa=${widget.upiID}&pn=VikasPasoriya&am=${_amt.text}&cu=INR";
                await launchUrl(Uri.parse(url));
                Navigator.pop(context);
              } catch (e) { print(e); }
              setState(() => _loading = false);
            },
            child: const Text('सेव करें और पेमेंट करें', style: TextStyle(color: Colors.white)),
          )
        ]),
      ),
    );
  }
}

// ---------------- 3. एडमिन पैनल (लॉगिन + कंट्रोल) ----------------
class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    final pass = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('एडमिन लॉगिन')),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        TextField(controller: pass, decoration: const InputDecoration(labelText: 'पासवर्ड दर्ज करें'), obscureText: true),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () {
          if (pass.text == "vikas@bhagwa") {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
          }
        }, child: const Text('लॉगिन करें'))
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
  final _ytC = TextEditingController();
  final _upiC = TextEditingController();
  final _aboutC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: const Text('एडमिन डैशबोर्ड'), bottom: const TabBar(tabs: [Tab(text: "डोनेशन लिस्ट"), Tab(text: "ऐप सेटिंग्स")])),
        body: TabBarView(children: [
          // डोनेशन देखने के लिए
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('donations').orderBy('time', descending: true).snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              return ListView.builder(itemCount: snap.data!.docs.length, itemBuilder: (context, i) {
                var d = snap.data!.docs[i];
                return ListTile(title: Text("${d['name']} - ₹${d['amount']}"), subtitle: Text(d['mobile']), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => d.reference.delete()));
              });
            },
          ),
          // यूट्यूब और यूपीआई बदलने के लिए
          Padding(padding: const EdgeInsets.all(20), child: ListView(children: [
            TextField(controller: _ytC, decoration: const InputDecoration(labelText: 'नया यूट्यूब लिंक')),
            TextField(controller: _upiC, decoration: const InputDecoration(labelText: 'नयी UPI ID')),
            TextField(controller: _aboutC, decoration: const InputDecoration(labelText: 'संस्था जानकारी'), maxLines: 3),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () async {
              await FirebaseFirestore.instance.collection('settings').doc('app_config').set({'youtube': _ytC.text, 'upi': _upiC.text, 'about': _aboutC.text}, SetOptions(merge: true));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('सिस्टम अपडेट हो गया!')));
            }, child: const Text('सब अपडेट करें'))
          ])),
        ]),
      ),
    );
  }
}
