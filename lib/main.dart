import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

void main() => runApp(const VikasHeavyApp());

class VikasHeavyApp extends StatelessWidget {
  const VikasHeavyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange, scaffoldBackgroundColor: const Color(0xFFFFFBF2)),
      home: const UserDashboard(),
    );
  }
}

// --- १. यूजर डैशबोर्ड (हेडलाइन वीडियो और डोनर लिस्ट के साथ) ---
class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  List<String> ytLinks = [];
  List<Map<String, dynamic>> donors = [];
  List<Map<String, dynamic>> monthlyDonors = [];
  String purnima = "लोड हो रहा है...";

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  _loadAllData() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      ytLinks = p.getStringList("ytLinks") ?? ["https://youtube.com"];
      purnima = p.getString("purnima") ?? "अगली पूर्णमासी का अपडेट जल्द आएगा।";
      
      // डोनर डेटा लोड करना
      String dJson = p.getString("donors") ?? "[]";
      donors = List<Map<String, dynamic>>.from(json.decode(dJson));
      
      String mJson = p.getString("monthlyDonors") ?? "[]";
      monthlyDonors = List<Map<String, dynamic>>.from(json.decode(mJson));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("विकास पासोरिया संस्था"),
        backgroundColor: Colors.orange[900],
        actions: [
          IconButton(icon: const Icon(Icons.admin_panel_settings), 
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLogin())).then((_) => _loadAllData()))
        ],
      ),
      body: Column(
        children: [
          // १. यूट्यूब हेडलाइन (Scrolling Links)
          Container(
            height: 50, color: Colors.red[900],
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: ytLinks.length,
              itemBuilder: (context, i) => InkWell(
                onTap: () => launchUrl(Uri.parse(ytLinks[i])),
                child: Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15), 
                child: Text("📺 वीडियो ${i+1}: ${ytLinks[i].split('v=')[0]}...", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
              ),
            ),
          ),
          
          // २. डोनर पट्टी (Scrolling Donor Names)
          if (donors.isNotEmpty)
            Container(height: 30, color: Colors.orange[100],
              child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: donors.length,
                itemBuilder: (context, i) => Center(child: Text(" ✨ ${donors[i]['name']} (${donors[i]['village']})  | ", style: const TextStyle(fontWeight: FontWeight.bold)))),
            ),

          Expanded(
            child: ListView(padding: const EdgeInsets.all(15), children: [
              _card("🌕 पूर्णमासी कार्यक्रम", purnima, Colors.orange),
              const SizedBox(height: 10),
              _btn("💰 डोनेशन करें (रशीद पाएँ)", Colors.green[800]!, Icons.currency_rupee, () => _showDonationDialog(false)),
              _btn("🗓️ मंथली डोनर बनें", Colors.blue[900]!, Icons.calendar_month, () => _showDonationDialog(true)),
              const Divider(height: 40),
              const Text("🏆 हमारे मंथली डोनर्स", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ...monthlyDonors.map((m) => ListTile(leading: const Icon(Icons.stars, color: Colors.amber), title: Text(m['name']), subtitle: Text(m['village']))),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _card(String t, String c, Color col) => Card(elevation: 4, child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: col)), const Divider(), Text(c)])));
  
  Widget _btn(String t, Color c, IconData i, VoidCallback tap) => Padding(padding: const EdgeInsets.only(bottom: 10), child: ElevatedButton.icon(icon: Icon(i), label: Text(t), style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55)), onPressed: tap));

  // --- डोनेशन और रशीद सिस्टम ---
  _showDonationDialog(bool isMonthly) {
    final n = TextEditingController(); final v = TextEditingController(); final m = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text(isMonthly ? "मंथली डोनर फॉर्म" : "डोनेशन रशीद"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: n, decoration: const InputDecoration(labelText: "आपका नाम")),
        TextField(controller: v, decoration: const InputDecoration(labelText: "गाँव")),
        TextField(controller: m, decoration: const InputDecoration(labelText: "मोबाइल नंबर")),
      ]),
      actions: [ElevatedButton(onPressed: () => _processDonation(n.text, v.text, m.text, isMonthly), child: const Text("रशीद जनरेट करें"))],
    ));
  }

  _processDonation(String name, String village, String phone, bool isMonthly) async {
    final p = await SharedPreferences.getInstance();
    Map<String, dynamic> newDonor = {"name": name, "village": village, "phone": phone, "date": DateTime.now().toString()};
    
    if (isMonthly) {
      monthlyDonors.add(newDonor);
      await p.setString("monthlyDonors", json.encode(monthlyDonors));
    } else {
      donors.add(newDonor);
      await p.setString("donors", json.encode(donors));
    }
    
    Navigator.pop(context);
    _showDigitalReceipt(newDonor);
    _loadAllData();
  }

  _showDigitalReceipt(Map d) {
    showDialog(context: context, builder: (c) => AlertDialog(
      backgroundColor: Colors.white,
      content: Container(padding: const EdgeInsets.all(10), border: Border.all(color: Colors.orange),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("विक़ास पासोरिया संस्था", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
          const Text("डिजिटल डोनेशन रशीद", style: TextStyle(fontSize: 14)),
          const Divider(),
          Text("नाम: ${d['name']}"), Text("गाँव: ${d['village']}"), Text("मोबाइल: ${d['phone']}"),
          const Divider(),
          const Text("🙏 दान देने के लिए धन्यवाद 🙏", style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
      ),
    ));
  }
}

// --- २. एडमिन लॉगिन ---
class AdminLogin extends StatelessWidget {
  const AdminLogin({super.key});
  @override
  Widget build(BuildContext context) {
    final pc = TextEditingController();
    return Scaffold(appBar: AppBar(title: const Text("Admin")), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      TextField(controller: pc, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: () { if(pc.text == "Vikas1998") Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const AdminDash())); }, child: const Text("Login"))
    ])));
  }
}

// --- ३. एडमिन डैशबोर्ड (सब कंट्रोल यहाँ तै) ---
class AdminDash extends StatefulWidget {
  const AdminDash({super.key});
  @override
  State<AdminDash> createState() => _AdminDashState();
}

class _AdminDashState extends State<AdminDash> {
  final _ytController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("संस्था एडमिन कंट्रोल"), backgroundColor: Colors.red[900]),
      body: ListView(padding: const EdgeInsets.all(15), children: [
        const Text("यूट्यूब लिंक जोड़ें (Comma लगाकै १०-२० लिंक डालें)", style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(controller: _ytController, maxLines: 3, decoration: const InputDecoration(hintText: "link1, link2, link3...", border: OutlineInputBorder())),
        ElevatedButton(onPressed: () async {
          final p = await SharedPreferences.getInstance();
          await p.setStringList("ytLinks", _ytController.text.split(',').map((e) => e.trim()).toList());
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("यूट्यूब हेडलाइन अपडेट हो गई!")));
        }, child: const Text("हेडलाइन अपडेट करें")),
        const Divider(height: 40),
        _tile(context, "पूर्णमासी अपडेट", "purnima"),
        _tile(context, "डोनर डेटा देखें", "donors_view"),
        _tile(context, "मंथली डोनर लिस्ट", "monthly_view"),
      ]),
    );
  }

  Widget _tile(BuildContext c, String t, String k) => ListTile(title: Text(t), trailing: const Icon(Icons.arrow_forward_ios), 
    onTap: () => Navigator.push(c, MaterialPageRoute(builder: (c) => EditPage(t: t, k: k))));
}

// --- ४. डेटा एडिटिंग और व्यूइंग पेज ---
class EditPage extends StatelessWidget {
  final String t, k;
  EditPage({super.key, required this.t, required this.k});
  final _c = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t)),
      body: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final p = snapshot.data as SharedPreferences;
          
          if (k.contains("view")) {
            String data = p.getString(k.replaceAll("_view", "")) ?? "[]";
            List list = json.decode(data);
            return ListView.builder(itemCount: list.length, itemBuilder: (c, i) => ListTile(title: Text(list[i]['name']), subtitle: Text("${list[i]['village']} - ${list[i]['phone']}")));
          }
          
          return Padding(padding: const EdgeInsets.all(20), child: Column(children: [
            TextField(controller: _c, maxLines: 5, decoration: const InputDecoration(border: OutlineInputBorder())),
            ElevatedButton(onPressed: () async { await p.setString(k, _c.text); Navigator.pop(context); }, child: const Text("सेव करें"))
          ]));
        },
      ),
    );
  }
}
