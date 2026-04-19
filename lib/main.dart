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

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  List<String> ytLinks = [];
  List<dynamic> donors = [];
  List<dynamic> monthlyDonors = [];
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
      purnima = p.getString("purnima") ?? "अपडेट जल्द आएगा।";
      donors = json.decode(p.getString("donors") ?? "[]");
      monthlyDonors = json.decode(p.getString("monthlyDonors") ?? "[]");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("विकास पासोरिया ऑफिशियल"),
        backgroundColor: Colors.orange[900],
        actions: [
          IconButton(icon: const Icon(Icons.admin_panel_settings), 
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLogin())).then((_) => _loadAllData()))
        ],
      ),
      body: Column(
        children: [
          // १. यूट्यूब हेडलाइन
          Container(
            height: 50, color: Colors.red[900],
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: ytLinks.length,
              itemBuilder: (context, i) => InkWell(
                onTap: () => launchUrl(Uri.parse(ytLinks[i])),
                child: Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15), 
                child: Text("📺 वीडियो ${i+1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
              ),
            ),
          ),
          
          // २. डोनर पट्टी (Scrolling Names)
          if (donors.isNotEmpty)
            Container(height: 30, color: Colors.orange[100],
              child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: donors.length,
                itemBuilder: (context, i) => Center(child: Text(" ✨ ${donors[i]['name']} (${donors[i]['village']}) | ", style: const TextStyle(fontWeight: FontWeight.bold)))),
            ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _card("🌕 पूर्णमासी कार्यक्रम", purnima, Colors.orange),
                  _btn("💰 डोनेशन (रशीद पाएँ)", Colors.green[800]!, Icons.currency_rupee, () => _showDonationDialog(false)),
                  _btn("🗓️ मंथली डोनर बनें", Colors.blue[900]!, Icons.calendar_month, () => _showDonationDialog(true)),
                  const Padding(padding: EdgeInsets.all(10), child: Text("🏆 हमारे मंथली डोनर्स", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  ...monthlyDonors.map((m) => ListTile(leading: const Icon(Icons.stars, color: Colors.amber), title: Text(m['name']), subtitle: Text(m['village']))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(String t, String c, Color col) => Card(margin: const EdgeInsets.all(10), elevation: 4, child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: col)), const Divider(), Text(c)])));
  
  Widget _btn(String t, Color c, IconData i, VoidCallback tap) => Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: ElevatedButton.icon(icon: Icon(i), label: Text(t), style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55)), onPressed: tap));

  _showDonationDialog(bool isMonthly) {
    final n = TextEditingController(); final v = TextEditingController(); final m = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text(isMonthly ? "मंथली डोनर" : "डोनेशन"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: n, decoration: const InputDecoration(labelText: "नाम")),
        TextField(controller: v, decoration: const InputDecoration(labelText: "गाँव")),
        TextField(controller: m, decoration: const InputDecoration(labelText: "मोबाइल")),
      ]),
      actions: [ElevatedButton(onPressed: () => _processDonation(n.text, v.text, m.text, isMonthly), child: const Text("रशीद जनरेट करें"))],
    ));
  }

  _processDonation(String name, String village, String phone, bool isMonthly) async {
    final p = await SharedPreferences.getInstance();
    Map<String, String> newD = {"name": name, "village": village, "phone": phone};
    if (isMonthly) { monthlyDonors.add(newD); await p.setString("monthlyDonors", json.encode(monthlyDonors)); }
    else { donors.add(newD); await p.setString("donors", json.encode(donors)); }
    Navigator.pop(context);
    _showReceipt(newD);
    _loadAllData();
  }

  _showReceipt(Map d) {
    showDialog(context: context, builder: (c) => AlertDialog(
      content: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(border: Border.all(color: Colors.orange, width: 2), borderRadius: BorderRadius.circular(10)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("विक़ास पासोरिया संस्था", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(),
          Text("डोनर: ${d['name']}"), Text("गाँव: ${d['village']}"),
          const SizedBox(height: 10),
          const Text("🙏 धन्यवाद 🙏")
        ]),
      ),
    ));
  }
}

class AdminLogin extends StatelessWidget {
  const AdminLogin({super.key});
  @override
  Widget build(BuildContext context) {
    final pc = TextEditingController();
    return Scaffold(appBar: AppBar(title: const Text("Admin")), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      TextField(controller: pc, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: () { if(pc.text == "Vikas1998") Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const AdminDash())); }, child: const Text("लॉगिन करें"))
    ])));
  }
}

class AdminDash extends StatefulWidget {
  const AdminDash({super.key});
  @override
  State<AdminDash> createState() => _AdminDashState();
}

class _AdminDashState extends State<AdminDash> {
  final _ytC = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("एडमिन कंट्रोल")),
      body: ListView(padding: const EdgeInsets.all(15), children: [
        const Text("यूट्यूब लिंक (कॉमा लगाकर डालें)"),
        TextField(controller: _ytC, maxLines: 2, decoration: const InputDecoration(border: OutlineInputBorder())),
        ElevatedButton(onPressed: () async {
          final p = await SharedPreferences.getInstance();
          await p.setStringList("ytLinks", _ytC.text.split(',').map((e) => e.trim()).toList());
        }, child: const Text("लिंक अपडेट करें")),
        ListTile(title: const Text("पूर्णमासी अपडेट"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => EditPage(k: "purnima")))),
      ]),
    );
  }
}

class EditPage extends StatelessWidget {
  final String k;
  EditPage({super.key, required this.k});
  final _c = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Edit")), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      TextField(controller: _c, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder())),
      ElevatedButton(onPressed: () async { 
        final p = await SharedPreferences.getInstance(); 
        await p.setString(k, _c.text); 
        Navigator.pop(context); 
      }, child: const Text("सेव करें"))
    ])));
  }
}
